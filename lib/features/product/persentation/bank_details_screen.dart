import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/financial_controller.dart';
import '../../../../core/theme/app_colors.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FinancialController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const AddBankAccountScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isFetching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bankData.isEmpty) {
          return const Center(
            child: Text(
              'No bank accounts added yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final data = controller.bankData;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBankAccountCard(
              context,
              bankName: data['bank_name']?.toString() ?? 'N/A',
              accountNumber: data['account_number_masked']?.toString() ?? 'N/A',
              ifsc: data['ifsc_code']?.toString() ?? 'N/A',
              holderName: data['account_holder_name']?.toString() ?? 'N/A',
              isDefault: data['is_active'] == true,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBankAccountCard(
    BuildContext context, {
    required String bankName,
    required String accountNumber,
    required String ifsc,
    required String holderName,
    required bool isDefault,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance, color: Colors.blue.shade400),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                bankName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(accountNumber),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete')],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 18, color: isDefault ? Colors.grey : Colors.amber),
                              const SizedBox(width: 8),
                              Text(isDefault ? 'Remove Default' : 'Set as Default'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Account Holder', holderName),
                _buildDetailRow('IFSC Code', ifsc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==================== ADD BANK ACCOUNT SCREEN ====================

class AddBankAccountScreen extends StatelessWidget {
  const AddBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FinancialController controller = Get.put(FinancialController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Add Bank Account",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.white10 : Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Bank Details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                  label: 'Account Holder Name',
                  icon: Icons.person_outline,
                  controller: controller.holderNameController,
                  isDark: isDark),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Bank Name', 
                  icon: Icons.account_balance, 
                  controller: controller.bankNameController,
                  isDark: isDark),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Account Number',
                  icon: Icons.numbers,
                  controller: controller.accountNumberController,
                  keyboardType: TextInputType.number,
                  isDark: isDark),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Confirm Account Number',
                  icon: Icons.numbers,
                  controller: controller.confirmAccountNumberController,
                  keyboardType: TextInputType.number,
                  isDark: isDark),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'IFSC Code', 
                  icon: Icons.code, 
                  controller: controller.ifscController,
                  isDark: isDark),
              const SizedBox(height: 16),
              
              // Account Type Dropdown
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedAccountType.value,
                    isExpanded: true,
                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    items: controller.accountTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type.capitalizeFirst ?? type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedAccountType.value = newValue;
                      }
                    },
                  ),
                ),
              )),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: isDark ? Colors.white54 : Colors.black45),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isDark ? Colors.white12 : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: controller.isLoading.value 
                        ? null 
                        : () async {
                          bool success = await controller.addBankAccount();
                          if (success) {
                            Get.back();
                          }
                        },
                      child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Add Account',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isDark = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.black54),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}