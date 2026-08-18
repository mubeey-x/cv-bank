import 'dart:io';

import 'package:cv_bank/features/people/data/models/person_document_model.dart';
import 'package:cv_bank/features/people/data/models/placement_model.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cv_bank/core/error/exceptions.dart';
import 'package:cv_bank/core/error/supabase_error_mapper.dart';
import 'package:cv_bank/core/utils/date_format.dart';
import 'package:cv_bank/core/utils/phone_normalizer.dart';
import '../../domain/entities/new_person.dart';
import '../../domain/entities/person_document.dart';
import '../../domain/entities/person_query.dart';
import '../models/person_model.dart';

/// Columns pulled for a list row. Deliberately narrow: the list shows
/// a name, a category, a phone and a badge, so fetching notes and CV
/// text for 30 rows would be wasted bytes on a slow connection.
const _listColumns = '''
  id, full_name, phone, category_id, status, relationship, received_on,
  categories(name),
  documents(count)
''';

abstract interface class PersonRemoteDataSource {
  Future<List<PersonModel>> search(PersonQuery query);
  Future<PersonModel> getById(String id);
  Future<PersonModel?> findByPhone(String phone);
  Future<PersonModel> insert(NewPerson draft);
  Future<PersonModel> update(String id, PersonUpdate changes);
  Future<void> archive(String id);

  Future<List<PersonDocumentModel>> fetchDocuments(String personId);
  Future<PersonDocumentModel> uploadDocument({
    required String personId,
    required DocumentUpload upload,
  });
  Future<String> signedUrl(String storagePath);
  Future<List<int>> downloadDocument(String storagePath);
  Future<void> deleteDocument(PersonDocument document);
  Future<ExtractedDetails> extractDetails(String storagePath);

  Future<PlacementModel> insertPlacement({
    required String personId,
    String? positionTitle,
    String? organisation,
    DateTime? startedOn,
  });
  Future<void> endCurrentPlacement(String personId);
  Future<List<PlacementModel>> fetchPlacements(String personId);
}

class PersonSupabaseDataSource implements PersonRemoteDataSource {
  final SupabaseClient client;
  const PersonSupabaseDataSource(this.client);

  String get _ownerId {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw const UnauthorizedException('Not signed in.');
    }
    return id;
  }

  // -------------------------------------------------------------------
  // People
  // -------------------------------------------------------------------

  @override
  Future<List<PersonModel>> search(PersonQuery query) =>
      mapSupabaseErrors(() async {
        // PostgREST rather than the search_people RPC, because the RPC
        // returns `setof people` and so cannot carry the joined
        // category name or document count.
        var q = client
            .from('people')
            .select(_listColumns)
            .isFilter('archived_at', null);

        if (query.categoryId != null) {
          q = q.eq('category_id', query.categoryId!);
        }
        if (query.status != null) {
          q = q.eq('status', query.status!.name);
        }
        if (query.relationship != null) {
          q = q.eq('relationship', query.relationship!.name);
        }
        if (query.qualification != null) {
          q = q.eq('qualification', query.qualification!.name);
        }

        final term = query.search?.trim();
        if (term != null && term.isNotEmpty) {
          final digits = PhoneNormalizer.digits(term);

          // Digits look like a phone lookup; anything else searches
          // the name and the extracted CV text.
          if (digits.length >= 4 &&
              digits.length == term.replaceAll(' ', '').length) {
            q = q.ilike('phone_key', '%${PhoneNormalizer.key(term)}%');
          } else {
            final escaped = term.replaceAll(',', ' ');
            q = q.or('full_name.ilike.%$escaped%,cv_text.ilike.%$escaped%');
          }
        }

        final rows = await q
            .order('received_on', ascending: false)
            .order('full_name')
            .range(query.offset, query.offset + query.limit - 1);

        return rows.map(PersonModel.fromJson).toList();
      });

  @override
  Future<PersonModel> getById(String id) => mapSupabaseErrors(() async {
    // placements is filtered to the current one only; an !inner
    // join would drop people who have never been placed, so the
    // select uses a plain embed with a filter instead.
    final row = await client
        .from('people')
        .select('''
              id, full_name, phone, category_id, status, relationship,
              received_on, email, qualification, course_of_study,
              institution, years_experience, current_occupation,
              referrer_name, channel, notes,
              categories(name),
              documents(count),
              placements(id, person_id, position_title, organisation,
                         started_on, ended_on, is_current)
            ''')
        .eq('id', id)
        .isFilter('archived_at', null)
        .maybeSingle();

    if (row == null) {
      throw const NotFoundException('That person is no longer here.');
    }

    // Keep only the active placement for currentPlacement.
    final placements = (row['placements'] as List?) ?? const [];
    row['placements'] = placements
        .where((pl) => (pl as Map)['is_current'] == true)
        .toList();

    return PersonModel.fromJson(row);
  });

  @override
  Future<PersonModel?> findByPhone(String phone) => mapSupabaseErrors(() async {
    final key = PhoneNormalizer.key(phone);
    if (key.isEmpty) return null;

    final row = await client
        .from('people')
        .select(_listColumns)
        .eq('phone_key', key)
        .isFilter('archived_at', null)
        .maybeSingle();

    return row == null ? null : PersonModel.fromJson(row);
  });

  @override
  Future<PersonModel> insert(NewPerson draft) => mapSupabaseErrors(() async {
    final inserted = await client
        .from('people')
        // owner_id defaults to auth.uid(), so it is never sent.
        .insert({
          'full_name': draft.fullName,
          'phone': draft.phone,
          if (draft.categoryId != null) 'category_id': draft.categoryId,
          if (draft.email != null) 'email': draft.email,
          if (draft.qualification != null)
            'qualification': draft.qualification!.name,
          if (draft.courseOfStudy != null)
            'course_of_study': draft.courseOfStudy,
          if (draft.institution != null) 'institution': draft.institution,
          if (draft.yearsExperience != null)
            'years_experience': draft.yearsExperience,
          if (draft.currentOccupation != null)
            'current_occupation': draft.currentOccupation,
          if (draft.referrerName != null) 'referrer_name': draft.referrerName,
          if (draft.channel != null) 'channel': channelToDb(draft.channel),
          'relationship': draft.relationship.name,
          if (draft.notes != null) 'notes': draft.notes,
        })
        .select(_listColumns)
        .single();

    return PersonModel.fromJson(inserted);
  });

  @override
  Future<PersonModel> update(String id, PersonUpdate changes) =>
      mapSupabaseErrors(() async {
        final payload = <String, dynamic>{
          if (changes.fullName != null) 'full_name': changes.fullName,
          if (changes.phone != null) 'phone': changes.phone,
          if (changes.categoryId != null) 'category_id': changes.categoryId,
          if (changes.email != null) 'email': changes.email,
          if (changes.qualification != null)
            'qualification': changes.qualification!.name,
          if (changes.courseOfStudy != null)
            'course_of_study': changes.courseOfStudy,
          if (changes.institution != null) 'institution': changes.institution,
          if (changes.yearsExperience != null)
            'years_experience': changes.yearsExperience,
          if (changes.currentOccupation != null)
            'current_occupation': changes.currentOccupation,
          if (changes.referrerName != null)
            'referrer_name': changes.referrerName,
          if (changes.channel != null) 'channel': channelToDb(changes.channel),
          if (changes.relationship != null)
            'relationship': changes.relationship!.name,
          if (changes.notes != null) 'notes': changes.notes,
        };

        if (payload.isEmpty) return getById(id);

        final row = await client
            .from('people')
            .update(payload)
            .eq('id', id)
            .select(_listColumns)
            .maybeSingle();

        if (row == null) {
          throw const NotFoundException('That person is no longer here.');
        }
        return PersonModel.fromJson(row);
      });

  @override
  Future<void> archive(String id) => mapSupabaseErrors(
    () => client
        .from('people')
        .update({'archived_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id),
  );

  // -------------------------------------------------------------------
  // Documents
  // -------------------------------------------------------------------

  @override
  Future<List<PersonDocumentModel>> fetchDocuments(String personId) =>
      mapSupabaseErrors(() async {
        final rows = await client
            .from('documents')
            .select()
            .eq('person_id', personId)
            .order('created_at', ascending: false);

        return rows.map(PersonDocumentModel.fromJson).toList();
      });

  @override
  Future<PersonDocumentModel> uploadDocument({
    required String personId,
    required DocumentUpload upload,
  }) => mapSupabaseErrors(() async {
    final file = File(upload.filePath);
    final ext = p.extension(upload.fileName);
    final stamp = DateTime.now().millisecondsSinceEpoch;

    // {owner_id}/{person_id}/... — the first segment is what the
    // storage policy checks against auth.uid().
    final path = '$_ownerId/$personId/$stamp$ext';

    await client.storage
        .from('cvs')
        .upload(
          path,
          file,
          fileOptions: FileOptions(contentType: upload.mimeType, upsert: false),
        );

    final row = await client
        .from('documents')
        .insert({
          'person_id': personId,
          'doc_type': upload.kind.name,
          'storage_path': path,
          'file_name': upload.fileName,
          'mime_type': upload.mimeType,
          'size_bytes': await file.length(),
        })
        .select()
        .single();

    return PersonDocumentModel.fromJson(row);
  });

  @override
  Future<String> signedUrl(String storagePath) => mapSupabaseErrors(
    () => client.storage.from('cvs').createSignedUrl(storagePath, 3600),
  );

  @override
  Future<List<int>> downloadDocument(String storagePath) => mapSupabaseErrors(
    () async =>
        (await client.storage.from('cvs').download(storagePath)).toList(),
  );

  @override
  Future<void> deleteDocument(PersonDocument document) =>
      mapSupabaseErrors(() async {
        await client.storage.from('cvs').remove([document.storagePath]);
        await client.from('documents').delete().eq('id', document.id);
      });

  @override
  Future<ExtractedDetails> extractDetails(String storagePath) =>
      mapSupabaseErrors(() async {
        final res = await client.functions.invoke(
          'extract-cv',
          body: {'storage_path': storagePath},
        );

        final data = res.data as Map<String, dynamic>?;
        if (data == null) return const ExtractedDetails();

        return ExtractedDetails(
          fullName: (data['full_name'] as String?)?.trim(),
          phone: (data['phone'] as String?)?.trim(),
          email: (data['email'] as String?)?.trim(),
        );
      });

  // -------------------------------------------------------------------
  // Placements
  // -------------------------------------------------------------------

  @override
  Future<PlacementModel> insertPlacement({
    required String personId,
    String? positionTitle,
    String? organisation,
    DateTime? startedOn,
  }) => mapSupabaseErrors(() async {
    // A unique index allows only one current placement per person,
    // so any existing one is closed first.
    await endCurrentPlacement(personId);

    final row = await client
        .from('placements')
        .insert({
          'person_id': personId,
          'position_title': ?positionTitle,
          'organisation': ?organisation,
          'started_on': AppDate.toIsoDate(startedOn ?? DateTime.now()),
          'is_current': true,
        })
        .select()
        .single();

    // people.status flips via the placements trigger, so nothing
    // updates it from here.
    return PlacementModel.fromJson(row);
  });

  @override
  Future<void> endCurrentPlacement(String personId) =>
      mapSupabaseErrors(() async {
        await client
            .from('placements')
            .update({
              'is_current': false,
              'ended_on': AppDate.toIsoDate(DateTime.now()),
            })
            .eq('person_id', personId)
            .eq('is_current', true);
      });

  @override
  Future<List<PlacementModel>> fetchPlacements(String personId) =>
      mapSupabaseErrors(() async {
        final rows = await client
            .from('placements')
            .select()
            .eq('person_id', personId)
            .order('started_on', ascending: false);

        return rows.map(PlacementModel.fromJson).toList();
      });
}
