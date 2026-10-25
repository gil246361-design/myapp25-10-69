import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class FirestoreService {
  static final _col = FirebaseFirestore.instance.collection('diaries');
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  static Future<void> add(WatchItem item) async {
    await _col.add({
      ...item.toFirestore(),
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<WatchItem>> watchMyItems() {
    return _col.where('userId', isEqualTo: _uid).snapshots().map((snap) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final docs = snap.docs.toList()
        ..sort((a, b) {
          final ta = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? now;
          final tb = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? now;
          return tb.compareTo(ta);
        });
      return docs.map((d) => WatchItem.fromFirestore(d.id, d.data())).toList();
    });
  }

  static Future<void> update(String docId, WatchItem item) async {
    await _col.doc(docId).update({
      ...item.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> delete(String docId) async {
    await _col.doc(docId).delete();
  }
}
