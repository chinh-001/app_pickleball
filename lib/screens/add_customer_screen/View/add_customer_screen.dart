import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_pickleball/screens/widgets/buttons/custom_action_button.dart';
import 'package:app_pickleball/services/localization/app_localizations.dart';
import 'package:app_pickleball/screens/add_customer_screen/bloc/add_customer_screen_bloc.dart';
import 'package:app_pickleball/models/customer_model.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? initialCustomer;

  const AddCustomerScreen({super.key, this.initialCustomer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  late final AddCustomerScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AddCustomerScreenBloc();

    // Khởi tạo dữ liệu nếu có initial customer
    if (widget.initialCustomer != null) {
      _lastNameController.text = widget.initialCustomer!.lastName;
      _firstNameController.text = widget.initialCustomer!.firstName;
      _emailController.text = widget.initialCustomer!.emailAddress ?? '';
      _phoneController.text = widget.initialCustomer!.phoneNumber ?? '';

      // Cập nhật bloc state
      _bloc.add(LastNameChanged(_lastNameController.text));
      _bloc.add(FirstNameChanged(_firstNameController.text));
      _bloc.add(EmailChanged(_emailController.text));
      _bloc.add(PhoneChanged(_phoneController.text));
      _bloc.add(NotesChanged(_notesController.text));
    }

    // Lắng nghe thay đổi text để cập nhật bloc
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
      child: BlocBuilder<AddCustomerScreenBloc, AddCustomerScreenState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text(
                AppLocalizations.of(context).translate('addCustomer'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 1,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildAddCustomerForm(context, state),
            ),
            bottomNavigationBar: _buildBottomBar(context, state),
          );
        },
      ),
    );
  }

  Widget _buildAddCustomerForm(
    BuildContext context,
    AddCustomerScreenState state,
  ) {
    final salutationOptions = [
      AppLocalizations.of(context).translate('mr'),
      AppLocalizations.of(context).translate('ms'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('salutation'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.selectedSalutation ?? salutationOptions.first,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items:
                        salutationOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<AddCustomerScreenBloc>().add(
                          SalutationChanged(value),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(
                          context,
                        ).translate('lastName'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(
                          context,
                        ).translate('firstName'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).translate('email'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).translate('phoneNumber'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          // Có thể thêm trường Notes nếu cần
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AddCustomerScreenState state) {
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
          CustomActionButton(
            text: AppLocalizations.of(context).translate('cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            isPrimary: false,
            fontSize: 13.0,
          ),
          const SizedBox(width: 12),
          CustomActionButton(
            text: AppLocalizations.of(context).translate('save'),
            onPressed: () {
              _saveCustomer(context, state);
            },
            isPrimary: true,
            isEnabled: _areRequiredFieldsFilled(state),
            fontSize: 13.0,
          ),
        ],
      ),
    );
  }

  bool _areRequiredFieldsFilled(AddCustomerScreenState state) {
    return state.lastName.isNotEmpty && state.firstName.isNotEmpty;
  }

  void _saveCustomer(BuildContext context, AddCustomerScreenState state) {
    // Validate thông tin bắt buộc
    if (state.lastName.isEmpty || state.firstName.isEmpty) {
      // Hiển thị SnackBar cảnh báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('fillRequiredFields'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Tạo Customer object từ state
    final customer = Customer(
      id: widget.initialCustomer?.id ?? '',
      firstName: state.firstName,
      lastName: state.lastName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phoneNumber: state.phone,
      emailAddress: state.email,
    );

    // Trả về customer object cho màn hình trước đó
    Navigator.of(context).pop(customer);
  }
}
