import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/listing_entity.dart';
import '../../domain/usecases/get_listings.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';

class HomePageDetailScreen extends StatelessWidget {
  final ListingEntity listing;
  const HomePageDetailScreen({required this.listing, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ListingBloc(context.read<GetListings>())..add(LoadListings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Listing Detail",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 1,
        ),
        body: BlocBuilder<ListingBloc, ListingState>(
          builder: (context, state) {
            if (state is ListingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ListingLoaded) {
              final ListingEntity listing = state.listings.first;
              return _buildListingDetails(listing);
            } else if (state is ListingError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildListingDetails(ListingEntity listing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              listing.photos.first.url,
              fit: BoxFit.cover,
              height: 250,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            listing.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                listing.location,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            "${listing.pricing.basePrice} ${listing.pricing.currency}",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            listing.description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),

          const SizedBox(height: 24),

          // Property Details Section
          const Text(
            "Property Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                _buildDetailRow("Property Type", "Apartment"),
                _buildDetailRow("Bedrooms", "2"),
                _buildDetailRow("Bathrooms", "1"),
                _buildDetailRow("Furnished", "Yes"),
                _buildDetailRow("Available From", "Immediately"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Amenities Section
          const Text(
            "Amenities",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityChip("WiFi"),
              _buildAmenityChip("Water"),
              _buildAmenityChip("Electricity"),
              _buildAmenityChip("Security"),
              _buildAmenityChip("Parking"),
              _buildAmenityChip("Kitchen"),
            ],
          ),

          const SizedBox(height: 24),

          // Roommate Preferences Section
          const Text(
            "Roommate Preferences",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Looking for a clean, quiet roommate who respects shared spaces. Preferably someone with similar lifestyle and schedule.",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),

          const SizedBox(height: 24),

          // Contact Information Section
          const Text(
            "Contact Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                _buildContactRow(Icons.person, "Posted by", "John Doe"),
                _buildContactRow(Icons.verified, "Verified", "Yes"),
                _buildContactRow(Icons.access_time, "Posted", "2 days ago"),
              ],
            ),
          ),

          const SizedBox(height: 32),
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
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        amenity,
        style: TextStyle(
          color: Colors.blue[700],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
