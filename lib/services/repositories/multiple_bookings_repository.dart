import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:developer' as log;

import '../../models/multiple_bookings_model.dart';
import '../interfaces/i_multiple_bookings_service.dart';
import '../api/api_client.dart';

class MultipleBookingsRepository implements IMultipleBookingsService {
  final GraphQLClient? client;

  MultipleBookingsRepository({this.client});

  @override
  Future<MultipleBookingsResponse> createMultipleBookings({
    required String channelToken,
    required MultipleBookingsInput input,
  }) async {
    log.log('===== BẮT ĐẦU TẠO MULTIPLE BOOKINGS =====');
    log.log('Channel Token: $channelToken');
    log.log('Input: ${input.toJson()}');

    final mutationString = '''
      mutation CreateMultipleBookings(\$input: CreateMultipleBookings!) {
        createMultipleBookings(input: \$input) {
          id
          createdAt
          updatedAt
          code
          qr_code
          booking_date
          start_time
          end_time
          total_price
          start_date
          deposit_amount
          deposit_paid
          end_date
          noteAdmin
          noteCustomer
          hex_code
          source
          type
          payment_method
          product {
            id
            createdAt
            updatedAt
            languageCode
            name
            slug
            description
            enabled
          }
          court {
            id
            createdAt
            updatedAt
            name
            addressCourt
            phoneCourt
            slug
            description
            start_time
            end_time
            hex_code
            qr_code
            enabled
          }
        }
      }
    ''';

    try {
      // Điều chỉnh cấu trúc đầu vào theo yêu cầu của API
      final adjustedInput = {
        'bookings': input.bookings.map((booking) => booking.toJson()).toList(),
      };

      log.log('Đã điều chỉnh Input: $adjustedInput');

      // Sử dụng ApiClient để thực hiện mutation
      final result = await ApiClient.instance.query<Map<String, dynamic>>(
        mutationString,
        variables: {'input': adjustedInput},
        channelToken: channelToken,
        converter: (json) => json,
      );

      if (result == null) {
        throw Exception('Không nhận được kết quả từ API');
      }

      if (result.containsKey('errors')) {
        final errors = result['errors'];
        log.log('GraphQL errors: $errors');
        throw Exception('GraphQL errors: $errors');
      }

      final data = result['data']?['createMultipleBookings'];
      if (data == null) {
        throw Exception(
          'Không có dữ liệu trả về từ mutation createMultipleBookings',
        );
      }

      log.log('===== TẠO MULTIPLE BOOKINGS THÀNH CÔNG =====');
      log.log('Response type: ${data.runtimeType}');
      log.log('Response: $data');

      // Kiểm tra nếu data là một List
      if (data is List) {
        if (data.isEmpty) {
          throw Exception('Danh sách booking trống');
        }
        // Lấy booking đầu tiên trong danh sách
        log.log('Trả về booking đầu tiên từ danh sách ${data.length} bookings');
        final firstBooking = data[0];
        if (firstBooking is Map<String, dynamic>) {
          // Kiểm tra và chuyển đổi kiểu dữ liệu nếu cần
          _validateAndConvertBookingData(firstBooking);
          return MultipleBookingsResponse.fromJson(firstBooking);
        } else {
          throw Exception(
            'Định dạng booking không hợp lệ: ${firstBooking.runtimeType}',
          );
        }
      } else if (data is Map<String, dynamic>) {
        // Nếu data là một Map, xử lý như bình thường
        // Kiểm tra và chuyển đổi kiểu dữ liệu nếu cần
        _validateAndConvertBookingData(data);
        return MultipleBookingsResponse.fromJson(data);
      } else {
        throw Exception('Định dạng dữ liệu không hợp lệ: ${data.runtimeType}');
      }
    } catch (error) {
      log.log('===== LỖI KHI TẠO MULTIPLE BOOKINGS =====');
      log.log('Error: $error');
      throw Exception('Lỗi khi tạo nhiều đặt sân: $error');
    }
  }

  // Kiểm tra và chuyển đổi kiểu dữ liệu trong dữ liệu booking
  void _validateAndConvertBookingData(Map<String, dynamic> booking) {
    log.log('Đang kiểm tra và chuyển đổi kiểu dữ liệu booking...');

    // Kiểm tra trường total_price
    if (booking.containsKey('total_price')) {
      log.log('total_price type: ${booking['total_price'].runtimeType}');
      if (booking['total_price'] is int) {
        booking['total_price'] = (booking['total_price'] as int).toDouble();
        log.log('Đã chuyển đổi total_price từ int sang double');
      }
    }

    // Kiểm tra trường deposit_amount
    if (booking.containsKey('deposit_amount')) {
      log.log('deposit_amount type: ${booking['deposit_amount'].runtimeType}');
      if (booking['deposit_amount'] is int) {
        booking['deposit_amount'] =
            (booking['deposit_amount'] as int).toDouble();
        log.log('Đã chuyển đổi deposit_amount từ int sang double');
      }
    }

    // Đảm bảo các trường chuỗi không bị null
    final stringFields = [
      'id',
      'createdAt',
      'updatedAt',
      'code',
      'qr_code',
      'booking_date',
      'start_time',
      'end_time',
      'start_date',
      'end_date',
      'noteAdmin',
      'noteCustomer',
      'hex_code',
      'source',
      'type',
      'payment_method',
    ];

    for (var field in stringFields) {
      if (booking.containsKey(field) && booking[field] == null) {
        booking[field] = '';
        log.log('Đã chuyển trường $field từ null thành chuỗi rỗng');
      }
    }

    // Kiểm tra các đối tượng con
    if (booking.containsKey('product') && booking['product'] != null) {
      _validateProductData(booking['product']);
    }

    if (booking.containsKey('court') && booking['court'] != null) {
      _validateCourtData(booking['court']);
    }
  }

  void _validateProductData(Map<String, dynamic> product) {
    final stringFields = [
      'id',
      'createdAt',
      'updatedAt',
      'languageCode',
      'name',
      'slug',
      'description',
    ];

    for (var field in stringFields) {
      if (product.containsKey(field) && product[field] == null) {
        product[field] = '';
        log.log('Đã chuyển trường product.$field từ null thành chuỗi rỗng');
      }
    }

    // Đảm bảo trường enabled là boolean
    if (product.containsKey('enabled') && product['enabled'] == null) {
      product['enabled'] = false;
    }
  }

  void _validateCourtData(Map<String, dynamic> court) {
    final stringFields = [
      'id',
      'createdAt',
      'updatedAt',
      'name',
      'addressCourt',
      'phoneCourt',
      'slug',
      'description',
      'start_time',
      'end_time',
      'hex_code',
      'qr_code',
    ];

    for (var field in stringFields) {
      if (court.containsKey(field) && court[field] == null) {
        court[field] = '';
        log.log('Đã chuyển trường court.$field từ null thành chuỗi rỗng');
      }
    }

    // Đảm bảo trường enabled là boolean
    if (court.containsKey('enabled') && court['enabled'] == null) {
      court['enabled'] = false;
    }
  }
}
