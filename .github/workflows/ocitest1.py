import oci

def list_fortigate_images():
    # Initialize the Marketplace Service client
    config = oci.config.from_file()  # Assumes default configuration. Adjust as necessary.
    marketplace_client = oci.marketplace.MarketplaceClient(config)

    # Define search criteria
    search_query = "FortiGate"

    # Search for listings
    search_details = oci.marketplace.models.SearchListingsDetails(
        name=search_query,
        limit=50  # Adjust based on expected number of results
    )

    # Perform search
    response = marketplace_client.search_listings(search_listings_details=search_details)

    for listing in response.data:
        print(f"Listing: {listing.name}, ID: {listing.id}")
        # List packages for each listing
        packages_response = marketplace_client.list_packages(listing_id=listing.id)
        for package in packages_response.data:
            print(f"  Package: {package.package_version}, OCID: {package.package_type}")

if __name__ == "__main__":
    list_fortigate_images()
