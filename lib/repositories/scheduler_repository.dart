import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/enums/schedule_type.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:intl/intl.dart';

import '../models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "schedules";

  /// Adicionar um novo agendamento
  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      final docRef = _firestore.collection(collectionName).doc();
      schedule.id = docRef.id;
      await docRef.set(schedule.toMap());
    } catch (e) {
      throw Exception("Erro ao adicionar agendamento: $e");
    }
  }

  /// Atualizar um agendamento existente
  Future<void> updateSchedule(String scheduleId, ScheduleModel schedule) async {
    try {
      await _firestore.collection(collectionName).doc(scheduleId).update(schedule.toMap());
    } catch (e) {
      throw Exception("Erro ao atualizar agendamento: $e");
    }
  }

  /// Deletar um agendamento
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection(collectionName).doc(scheduleId).delete();
    } catch (e) {
      throw Exception("Erro ao deletar agendamento: $e");
    }
  }

  /// Obter agendamento por ID
  Future<ScheduleModel?> getScheduleById(String scheduleId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(scheduleId).get();
      if (doc.exists) {
        return ScheduleModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar agendamento: $e");
    }
  }

  /// Obter agendamentos por usuário
  Stream<List<ScheduleModel>> getSchedulesByUserIdCompanyId() {
    try {
      return _firestore
          .collection(collectionName)
          .where('userAdvId', isEqualTo: Preferences.getString('userId'))
          .where('companyId', isEqualTo: Preferences.getString('companyId'))
          .orderBy('date', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ScheduleModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      throw Exception("Erro ao buscar agendamentos: $e");
    }
  }

  Future<int> getUpcomingSchedulesCount() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int totalUpcoming = 0;

      // Consulta os agendamentos a partir da data atual
      QuerySnapshot querySnapshot = await firestore
          .collection('schedules')
          .where('date', isGreaterThanOrEqualTo: todayDate)
          .where('companyId', isEqualTo: Preferences.getString('companyId'))
          .where('userId', isEqualTo: Preferences.getString('userId'))
          .get();

      QuerySnapshot querySnapshot2 = await firestore
          .collection('schedules')
          .where('date', isGreaterThanOrEqualTo: todayDate)
          .where('userId', isEqualTo: Preferences.getString('userId'))
          .where('companyId', isNull: true)
          .where('scheduleType', isEqualTo: ScheduleType.INDIVIDUAL.name)
          .get();

      totalUpcoming = querySnapshot.size + querySnapshot2.size;

      return totalUpcoming;
    }catch(e) {
      throw Exception("Erro ao buscar agendamentos: $e");
    }
  }

  /// Obter agendamentos por usuário
  Future<List<ScheduleModel>> getSchedulesByUserId() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final String userId = Preferences.getString('userId');

      // 🔍 1️⃣ Query para registros com companyId correspondente OU sem companyId (nulo ou vazio)
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId).get();

      if (querySnapshot.docs.isEmpty) {
        print("📌 Nenhum agendamento encontrado.");
        return [];
      }

      return querySnapshot.docs
          .map((doc) => ScheduleModel.fromMap(doc.data()))
          .toList();

    } catch (e) {
      throw Exception("Erro ao buscar agendamentos: $e");
    }
  }

  Future<List<ScheduleModel>> getSchedules({required int month, required int year}) async {
    try {
      final String userId = Preferences.getString('userId');
      final String companyId = Preferences.getString('companyId');

      QuerySnapshot querySnapshot = await _firestore
          .collection("schedules")
          .where("userId", isEqualTo: userId)
          .where(Filter.or(
          Filter('companyId', isEqualTo: companyId),
          Filter('companyId', isNull: true),
          Filter('companyId', isEqualTo: '')
          )).orderBy('date', descending: false).get();

      List<ScheduleModel> schedules = querySnapshot.docs
          .map((doc) => ScheduleModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((schedule) {
        DateTime scheduleDate = DateTime.parse(schedule.date);
        return scheduleDate.month == month && scheduleDate.year == year;
      }).toList();

      return schedules;
    } catch (e) {
      print("Erro ao buscar agendamentos: $e");
      return [];
    }
  }

  /// Obter agendamentos por usuário
  Stream<List<ScheduleModel>> getSchedulesByUserIdAndRap(String userId, String rapId) {
    try {
      return _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .where('companyId', isEqualTo: Preferences.getString('companyId'))
          .where('rapId', isEqualTo: rapId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ScheduleModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      throw Exception("Erro ao buscar agendamentos: $e");
    }
  }

  /// Obter agendamentos por RAP
  Stream<List<ScheduleModel>> getSchedulesByRapId(String rapId) {
    try {
      return _firestore
          .collection(collectionName)
          .where('rapId', isEqualTo: rapId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ScheduleModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      throw Exception("Erro ao buscar agendamentos por RAP: $e");
    }
  }

  /// Obter todos os agendamentos
  Stream<List<ScheduleModel>> getAllSchedules() {
    try {
      return _firestore.collection(collectionName).snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => ScheduleModel.fromMap(doc.data())).toList());
    } catch (e) {
      throw Exception("Erro ao buscar todos os agendamentos: $e");
    }
  }
}