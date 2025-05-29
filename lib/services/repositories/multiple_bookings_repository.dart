import 'package:graphql/client.dart';
import 'dart:convert';

import '../../models/multiple_bookings_model.dart';
import '../interfaces/i_multiple_bookings_service.dart';

class MultipleBookingsRepository implements IMultipleBookingsService {
  final GraphQLClient client;

  MultipleBookingsRepository({required this.client});

  @override
  Future<MultipleBookingsResponse> createMultipleBookings({
    required String channelToken,
    required MultipleBookingsInput input,
  }) async {
    final mutationString = '''
      mutation CreateMultipleBookings(\$input: CreateMultipleBookingsInput!) {
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
      // Tạo AuthLink để thêm header Authorization
      final AuthLink authLink = AuthLink(
        getToken: () => 'Bearer $channelToken',
      );

      // Kết hợp AuthLink với link hiện tại của client
      final Link link = authLink.concat(client.link);

      // Tạo client mới với link đã thêm header
      final authorizedClient = GraphQLClient(cache: client.cache, link: link);

      final options = MutationOptions(
        document: gql(mutationString),
        variables: {'input': input.toJson()},
        fetchPolicy: FetchPolicy.noCache,
      );

      final result = await authorizedClient.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final data = result.data?['createMultipleBookings'];
      if (data == null) {
        throw Exception(
          'Không có dữ liệu trả về từ mutation createMultipleBookings',
        );
      }

      return MultipleBookingsResponse.fromJson(data);
    } catch (error) {
      throw Exception('Lỗi khi tạo nhiều đặt sân: $error');
    }
  }
}
