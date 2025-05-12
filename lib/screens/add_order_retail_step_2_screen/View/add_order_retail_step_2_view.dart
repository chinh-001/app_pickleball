import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/widgets/custom_dropdown.dart';
import 'package:app_pickleball/screens/widgets/custom_multiline_text_field.dart';
import 'package:app_pickleball/screens/add_order_retail_step_2_screen/bloc/add_order_retail_step_2_screen_bloc.dart';

class AddOrderRetailStep2View extends StatefulWidget {
  const AddOrderRetailStep2View({super.key});

  @override
  State<AddOrderRetailStep2View> createState() =>
      _AddOrderRetailStep2ViewState();
}

class _AddOrderRetailStep2ViewState extends State<AddOrderRetailStep2View> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  late final AddOrderRetailStep2ScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AddOrderRetailStep2ScreenBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.add(
        InitializeForm(
          defaultPaymentMethod: AppLocalizations.of(context).translate('cash'),
        ),
      );

      // Listen for text field changes to update bloc state
      _lastNameController.addListener(() {
        _bloc.add(LastNameChanged(_lastNameController.text));
      });

      _firstNameController.addListener(() {
        _bloc.add(FirstNameChanged(_firstNameController.text));
      });

      _emailController.addListener(() {
        _bloc.add(EmailChanged(_emailController.text));
      });

      _phoneController.addListener(() {
        _bloc.add(PhoneChanged(_phoneController.text));
      });

      _notesController.addListener(() {
        _bloc.add(NotesChanged(_notesController.text));
      });
    });
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocBuilder<
        AddOrderRetailStep2ScreenBloc,
        AddOrderRetailStep2ScreenState
      >(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text(
                AppLocalizations.of(context).translate('addNew'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 1,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepper(context),
                  const SizedBox(height: 24),
                  _buildCustomerSection(context, state),
                  const SizedBox(height: 24),
                  _buildPaymentMethodSection(context, state),
                  const SizedBox(height: 24),
                  _buildPaymentStatusSection(context, state),
                  const SizedBox(height: 24),
                  _buildOrderStatusSection(context, state),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(context),
          );
        },
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Container(
      color: Colors.green,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStepCircle('1', false, true),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('courtInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            _buildStepCircle('2', true, false),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('customerInformation'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            _buildStepCircle('3', false, false),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).translate('completeBooking'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(String text, bool isActive, bool isDone) {
    return isActive
        ? CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
        : Container(
          width: 24,
          height: 24,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            shape: BoxShape.circle,
            color: isDone ? Colors.white : Colors.transparent,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isDone ? Colors.green : Colors.white,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
  }

  Widget _buildCustomerSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    final salutationOptions = [
      AppLocalizations.of(context).translate('mr'),
      AppLocalizations.of(context).translate('ms'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppLocalizations.of(context).translate('customer')} *',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              label: Text(
                AppLocalizations.of(context).translate('addCustomer'),
                style: const TextStyle(color: Colors.green),
              ),
              onPressed: () {
                // Handle add new customer
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          title: AppLocalizations.of(context).translate('salutation'),
          options: salutationOptions,
          selectedValue: state.selectedSalutation ?? salutationOptions.first,
          onChanged: (value) {
            if (value != null) {
              context.read<AddOrderRetailStep2ScreenBloc>().add(
                SalutationChanged(value),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: _lastNameController,
                label:
                    '${AppLocalizations.of(context).translate('lastName')} *',
                initialValue: state.lastName,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                controller: _firstNameController,
                label:
                    '${AppLocalizations.of(context).translate('firstName')} *',
                initialValue: state.firstName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _emailController,
          label: AppLocalizations.of(context).translate('email'),
          keyboardType: TextInputType.emailAddress,
          initialValue: state.email,
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _phoneController,
          label: AppLocalizations.of(context).translate('phoneNumber'),
          keyboardType: TextInputType.phone,
          initialValue: state.phone,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('notes'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomMultilineTextField(
              controller: _notesController,
              hintText: AppLocalizations.of(context).translate('notes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? initialValue,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    // If initialValue is provided and controller is empty, set the text
    if (initialValue != null &&
        initialValue.isNotEmpty &&
        controller.text.isEmpty) {
      controller.text = initialValue;
    }

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildRadioGroupSection({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children:
              options.map((option) {
                bool isSelected = currentValue == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onChanged(option);
                    }
                  },
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  backgroundColor: Colors.grey.shade50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('paymentMethod'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildOptionsContainer([
          _buildOption(
            icon: Icons.money,
            title: AppLocalizations.of(context).translate('cash'),
            isSelected:
                state.paymentMethod ==
                AppLocalizations.of(context).translate('cash'),
            iconColor: Colors.green,
            onTap:
                () => _bloc.add(
                  PaymentMethodChanged(
                    AppLocalizations.of(context).translate('cash'),
                  ),
                ),
          ),
          _buildOption(
            icon: Icons.account_balance_wallet,
            title: AppLocalizations.of(context).translate('eWallet'),
            isSelected:
                state.paymentMethod ==
                AppLocalizations.of(context).translate('eWallet'),
            iconColor: const Color(0xFF0068FF),
            onTap:
                () => _bloc.add(
                  PaymentMethodChanged(
                    AppLocalizations.of(context).translate('eWallet'),
                  ),
                ),
          ),
          _buildOption(
            icon: Icons.account_balance,
            title: AppLocalizations.of(context).translate('bankTransfer'),
            isSelected:
                state.paymentMethod ==
                AppLocalizations.of(context).translate('bankTransfer'),
            iconColor: const Color(0xFF1B7146),
            onTap:
                () => _bloc.add(
                  PaymentMethodChanged(
                    AppLocalizations.of(context).translate('bankTransfer'),
                  ),
                ),
          ),
        ]),
        const SizedBox(height: 20),
        _buildPaymentSummary(context),
      ],
    );
  }

  Widget _buildOptionsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isSelected,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('paymentDetails'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            AppLocalizations.of(context).translate('bookingPrice'),
            '477,000đ',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            AppLocalizations.of(context).translate('serviceFee'),
            '37,700đ',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            AppLocalizations.of(context).translate('discount'),
            '-29,700đ',
            valueColor: Colors.red,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            context,
            AppLocalizations.of(context).translate('totalPayment'),
            '485,000đ',
            isTotal: true,
            valueColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('paymentStatus'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildOptionsContainer([
          _buildOption(
            icon: Icons.error_outline,
            title: AppLocalizations.of(context).translate('unpaid'),
            isSelected:
                state.paymentStatus ==
                AppLocalizations.of(context).translate('unpaid'),
            iconColor: Colors.red,
            onTap:
                () => _bloc.add(
                  PaymentStatusChanged(
                    AppLocalizations.of(context).translate('unpaid'),
                  ),
                ),
          ),
          _buildOption(
            icon: Icons.check_circle_outline,
            title: AppLocalizations.of(context).translate('paid'),
            isSelected:
                state.paymentStatus ==
                AppLocalizations.of(context).translate('paid'),
            iconColor: Colors.green,
            onTap:
                () => _bloc.add(
                  PaymentStatusChanged(
                    AppLocalizations.of(context).translate('paid'),
                  ),
                ),
          ),
          _buildOption(
            icon: Icons.account_balance_wallet_outlined,
            title: AppLocalizations.of(context).translate('deposit'),
            isSelected:
                state.paymentStatus ==
                AppLocalizations.of(context).translate('deposit'),
            iconColor: Colors.orange,
            onTap:
                () => _bloc.add(
                  PaymentStatusChanged(
                    AppLocalizations.of(context).translate('deposit'),
                  ),
                ),
          ),
        ]),
      ],
    );
  }

  Widget _buildOrderStatusSection(
    BuildContext context,
    AddOrderRetailStep2ScreenState state,
  ) {
    final orderStatusOptions = [AppLocalizations.of(context).translate('new')];

    return _buildRadioGroupSection(
      title: '${AppLocalizations.of(context).translate('status')}:',
      currentValue: state.orderStatus,
      options: orderStatusOptions,
      onChanged: (value) {
        if (value != null) {
          context.read<AddOrderRetailStep2ScreenBloc>().add(
            OrderStatusChanged(value),
          );
        }
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {
              // Handle Cancel
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).translate('cancel'),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Handle Confirm
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Or other primary color
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).translate('confirm'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for text form fields - consider moving to a common widgets file
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isRequired;
  final TextInputType keyboardType;
  final int maxLines;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 16.0,
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$labelText không được để trống';
        }
        return null;
      },
    );
  }
}
