import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lockers_app/models/student.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../infrastructure/db_service.dart';
import '../models/locker.dart';

class LockerStudentProvider with ChangeNotifier {
  final List<Locker> _lockerItems = [];
  final List<Student> _studentItems = [];

  LockerStudentProvider(this.dbService);
  final DBService dbService;

  List<Locker> get lockerItems {
    return [..._lockerItems];
  }

  List<Student> get studentItems {
    return [..._studentItems];
  }

  Future<void> fetchAndSetLockers() async {
    _lockerItems.clear();
    final data = await dbService.getAllLockers();
    _lockerItems.addAll(data);
    notifyListeners();
  }

  Future<void> addLocker(Locker locker) async {
    final data = await dbService.addLocker(locker);
    _lockerItems.add(data);
    notifyListeners();
  }

  Future<void> updateLocker(Locker updatedLocker) async {
    final lockerIndex = findIndexOfLockerById(updatedLocker.id!);
    if (lockerIndex >= 0) {
      final newLocker = await dbService.updateLocker(updatedLocker);
      _lockerItems[lockerIndex] = newLocker;
      notifyListeners();
    }
  }

  Future<void> deleteLocker(String id) async {
    await dbService.deleteLocker(id);
    Locker item = _lockerItems.firstWhere((locker) => locker.id == id);

    _lockerItems.remove(item);
    notifyListeners();
  }

  Future<void> insertLocker(int index, Locker locker) async {
    await dbService.updateLocker(locker);
    _lockerItems.insert(index, locker);
    notifyListeners();
  }

  Locker getLocker(String id) {
    final lockerIndex = lockerItems.indexWhere((locker) => locker.id == id);
    return _lockerItems[lockerIndex];
  }

  List<Locker> getAvailableLockers() {
    List<Locker> availableItem =
        lockerItems.where((element) => element.isAvailable == true).toList();
    return availableItem;
  }

  int findIndexOfLockerById(String id) {
    final lockerIndex = _lockerItems.indexWhere((locker) => locker.id == id);
    return lockerIndex;
  }

  Future<void> fetchAndSetStudents() async {
    _studentItems.clear();
    final data = await dbService.getAllStudents();
    _studentItems.addAll(data);
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    final data = await dbService.addStudent(student);
    _studentItems.add(data);
    notifyListeners();
  }

  Future<void> updateStudent(Student updatedStudent) async {
    final studentIndex = findIndexOfStudentById(updatedStudent.id!);
    if (studentIndex >= 0) {
      final newStudent = await dbService.updateStudent(updatedStudent);
      _studentItems[studentIndex] = newStudent;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    await dbService.deleteStudent(id);
    _studentItems.removeWhere((student) => student.id == id);
    notifyListeners();
  }

  Future<void> insertStudent(int index, Student student) async {
    await dbService.updateStudent(student);
    _studentItems.insert(index, student);
    notifyListeners();
  }

  Student getStudent(String id) {
    if (id == "") return Student.base();

    final studentIndex = findIndexOfStudentById(id);
    return _studentItems[studentIndex];
  }

  List<Student> getAvailableStudents() {
    List<Student> availableItem =
        studentItems.where((element) => element.lockerNumber == 0).toList();
    return availableItem;
  }

  int findIndexOfStudentById(String id) {
    final studentIndex =
        _studentItems.indexWhere((student) => student.id == id);
    return studentIndex;
  }

  Future<void> attributeLocker(Locker locker, Student student) async {
    await updateLocker(
      locker.copyWith(
        isAvailable: false,
        idEleve: student.id,
      ),
    );

    await updateStudent(
      student.copyWith(
        lockerNumber: locker.lockerNumber,
      ),
    );
  }

  
  Future<void> importStudentsWithCSV(FilePickerResult? result) async {
    if (result != null) {
      final file = result.files.first;
      final filePath = file.path;
      final mimeType = filePath != null ? lookupMimeType(filePath) : null;
      final contentType = mimeType != null ? MediaType.parse(mimeType) : null;

      final fileReadStream = file.readStream;
      if (fileReadStream == null) {
        throw Exception('Cannot read file from null stream');
      }
      final stream = http.ByteStream(fileReadStream);

      final uri = Uri.https('siasky.net', '/skynet/skyfile');
      final request = http.MultipartRequest('POST', uri);
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        file.size,
        filename: file.name,
        contentType: contentType,
      );
      request.files.add(multipartFile);

      final httpClient = http.Client();
      final response = await httpClient.send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = await response.stream.transform(utf8.decoder).join();

      print(body);
    } else {
      throw Exception('Fichier non trouvé');
    }
  }
}
