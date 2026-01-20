import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/network/api_services.dart';
import '../../../dashboard/controller/follow_controller.dart';
import '../../model/contact_model.dart';

/*
class ContactController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Contact> contacts = <Contact>[].obs;

  @override
  void onInit() {
    fetchContacts();
    super.onInit();
  }

  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;

      // Request permission
      //bool permission = await FlutterContacts.requestPermission();
      bool permission = await Permission.contacts.request().isGranted;
      if (!permission) {
        print("Permission denied");
        return;
      }

      // Fetch contacts
      List<Contact> allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      contacts.value = allContacts;

      print("contactlist : "+contacts.value.toString());
      print("contactlist : "+allContacts.toString());
    } catch (e) {
      print("Error fetching contacts: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
*/



class ContactController extends GetxController {
  final ApiServices api = Get.put(ApiServices());

  RxBool isLoading = false.obs;

  /// Device contacts
  RxList<Contact> contacts = <Contact>[].obs;

  /// API se jo users milenge
  RxList<SyncedContact> syncedContacts = <SyncedContact>[].obs;
  RxList<SyncedContact> filteredContactList = <SyncedContact>[].obs;

  final FollowController followController = Get.put(FollowController());


  @override
  void onInit() {
    super.onInit();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;

      bool permission = await Permission.contacts.request().isGranted;
      if (!permission) return;

      contacts.value = await FlutterContacts.getContacts(withProperties: true,
      );

      /// Contacts milte hi API hit karo
      await syncContactsWithApi();
    } catch (e) {
      print("Fetch Contacts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔗 CONTACT SYNC API
 /* Future<void> syncContactsWithApi() async {
    try {
      /// 1️⃣ Numbers nikaalo
      List<String> numbers = [];

      for (var contact in contacts) {
        for (var phone in contact.phones) {
          if (phone.number.isNotEmpty) {
            numbers.add(phone.number);
          }
        }
      }

      if (numbers.isEmpty) return;

      /// 2️⃣ API call
      final response = await api.callPost(
        "api/v1/contacts/sync",
        data: {
          "country_code": "+91", // optional
          "numbers": numbers,
        },
      );

      print("Sync Response: $response");
      print("contact number : $numbers");

      /// 3️⃣ Response parse
      if (response != null && response["data"] != null) {
        syncedContacts.value = List<SyncedContact>.from(response["data"].map((e) => SyncedContact.fromJson(e),),);

        filteredContactList.value = List<SyncedContact>.from(response["data"].map((e) => SyncedContact.fromJson(e),),);

      }
    } catch (e) {
      print("Sync Error: $e");
    }
  }*/


  Future<void> syncContactsWithApi() async {
    try {
      /// 1️⃣ Prepare contacts with number + name
      List<Map<String, String>> contactsData = [];

      for (var contact in contacts) {
        String contactName = contact.displayName; // Name of the contact

        for (var phone in contact.phones) {
          String phoneNumber = phone.number.trim();
          if (phoneNumber.isNotEmpty) {
            contactsData.add({
              "phone": phoneNumber,
              "name": contactName,
            });
          }
        }
      }

      if (contactsData.isEmpty) return;

      /// 2️⃣ API call
      final response = await api.callPost(
        "api/v1/contacts/sync",
        data: {
          "country_code": "+91", // optional
          "contacts": contactsData,
        },
      );

      print("Sync Response: $response");
      print("Contacts sent: $contactsData");

      /// 3️⃣ Response parse
      if (response != null && response["data"] != null) {
        syncedContacts.value = List<SyncedContact>.from(
          response["data"].map((e) => SyncedContact.fromJson(e)),
        );

        filteredContactList.value = List<SyncedContact>.from(
          response["data"].map((e) => SyncedContact.fromJson(e)),
        );
      }
    } catch (e) {
      print("Sync Error: $e");
    }
  }


  Future<void> toggleFollowForPostUser(int userId) async {
    try {
      // Toggle follow through FollowController
      await followController.toggleFollow(userId);

      // ✅ Update ONLY posts where this user exists
      for (var post in syncedContacts) {
        if (post.id == userId) {
          post.isFollower = followController.isUserFollowing(userId).value as RxBool;
        }
      }

      // Refresh the posts list to update UI
      syncedContacts.refresh();
    } catch (e) {
      print("Follow Error: $e");
    }
  }


  void searchedPerson(String query) {
    if (query.isEmpty) {
      filteredContactList.assignAll(syncedContacts);
    } else {
      filteredContactList.assignAll(
        syncedContacts.where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase())
           || user.username!.toLowerCase().contains(query.toLowerCase())
        ),
      );
    }
  }

}


