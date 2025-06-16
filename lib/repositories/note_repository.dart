import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/note_model.dart';

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "notes";

  Future<void> addNote(NoteModel note) async {
    try {
      await _firestore.collection(collectionName).add(note.toMap());
    } catch (e) {
      throw Exception("Falha ao adicionar nota: $e");
    }
  }

  Future<void> updateNote(String noteId, NoteModel note) async {
    try {
      await _firestore.collection(collectionName).doc(noteId).update(note.toMap());
    } catch (e) {
      throw Exception("Falha ao atualizar nota: $e");
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection(collectionName).doc(noteId).delete();
    } catch (e) {
      throw Exception("Falha ao deletar nota: $e");
    }
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(noteId).get();
      if (doc.exists) {
        return NoteModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Falha ao buscar nota: $e");
    }
  }

  Future<List<NoteModel>> fetchNotesByRapId(String rapId) async {
    try {
      final notesQuery = await _firestore
          .collection(collectionName)
          .where("rapId", isEqualTo: rapId)
          .get();

      return notesQuery.docs.map((doc) => NoteModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception("Erro ao buscar notas para o RAP: $e");
    }
  }

  Future<List<NoteModel>> fetchNotesByProcessoId(String rapId) async {
    try {
      final notesQuery = await _firestore
          .collection(collectionName)
          .where("processoId", isEqualTo: rapId)
          .orderBy('createdAt', descending: true)
          .get();

      return notesQuery.docs.map((doc) => NoteModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception("Erro ao buscar notas para o Processo: $e");
    }
  }

  Stream<List<NoteModel>> getNotesByUserId(String userId) {
    try {
      return _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      throw Exception("Falha ao buscar notas: $e");
    }
  }

  Stream<List<NoteModel>> getAllNotes() {
    try {
      return _firestore
          .collection(collectionName)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      throw Exception("Falha ao buscar todas as notas: $e");
    }
  }

  Future<int> fetchNotesCount(String rapId) async {
    try {
      final notesQuery = await _firestore
          .collection(collectionName)
          .where("rapId", isEqualTo: rapId)
          .get();

      return notesQuery.docs.length;
    } catch (e) {
      throw Exception("Erro ao contar notas: $e");
    }
  }
}
