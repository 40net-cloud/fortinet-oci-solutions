import oci
import json
import datetime
import os

class FTNTMarketplace:
    def __init__(self):
        self.config = {
            "user": os.environ["USER_OCID"],
            "key_file": "~/.oci/oci_api_key.pem",
            "fingerprint": os.environ["FINGERPRINT"],
            "tenancy": os.environ["TENANCY_OCID"],
            "region": os.environ["REGION"]
        }
        self.marketplace_client = oci.marketplace.MarketplaceClient(self.config)
        self.listings = None
        self.get_listing()
        self.get_packages()
        self.get_images()

        self.final_listings = []
        self.convert_to_simple_list()
        self.write_final_listings_to_json()

    def get_listing(self):
        compartment_id = self.config["tenancy"]  # Tenancy OCID (or a specific compartment OCID)
        publisher_id = "28061011"
        listings = []
        try:
            response = self.marketplace_client.list_listings(
                compartment_id=compartment_id,
                publisher_id=publisher_id,
                sort_order="DESC",  # Order: ASC (ascending) or DESC (descending)
                limit=100  # Limit the number of results (optional)
            )
            for listing in response.data:
                listings.append({"listing_id": listing.id, "name": listing.name, "publisher": listing.publisher,
                                 "pricing_types": listing.pricing_types, "package_type": listing.package_type,
                                 "compatible_architectures": listing.compatible_architectures, "raw_data": listing, "packages": []})
        except oci.exceptions.ServiceError as e:
            print(f"Error fetching marketplace listings: {e}")
        self.listings = listings

    def get_packages(self):
        for listing in self.listings:
            if listing["package_type"] == "IMAGE":
                response = self.marketplace_client.list_packages(listing_id=listing["listing_id"])
                packages =  response.data
                for package in packages:
                    listing["packages"].append(self.parse_pacakge(package))

    @staticmethod
    def parse_pacakge(tmp):
        tmp = str(tmp)
        tmp = tmp.replace("{","").replace("}","").strip()
        tmp_list = tmp.split(",")
        listing_id = tmp_list[0].split(":")[1].strip().replace("\"","")
        package_type = tmp_list[1].split(":")[1].strip().replace("\"","")
        package_version = tmp_list[2].split(":")[1].strip().replace("\"", "")
        pricing = tmp_list[3].split(":")[1].strip().replace("\"","")
        regions = tmp_list[4].split(":")[1].strip().replace("\"", "")
        resource_id = tmp_list[5].split(":")[1].strip().replace("\"", "")
        tmp_dict = {"listing_id":listing_id, "package_type":package_type, "package_version":package_version, "pricing":pricing, "regions":regions, "resource_id":resource_id}
        return tmp_dict

    def get_images(self):
        for listing in self.listings:
            if listing["package_type"] == "IMAGE":
                for package in listing["packages"]:
                    response = self.marketplace_client.get_package(package_version=package["package_version"], listing_id=listing["listing_id"])
                    package["package_info"] = response.data

    def convert_to_simple_list(self):
        for listing in self.listings:
            tmp = { "listing_id":listing["listing_id"],"name":listing["name"],"packages": listing["packages"] }
            self.final_listings.append(tmp)

    def write_final_listings_to_json(self, filename='final_listings.json'):
        def serialize(obj):
            if isinstance(obj, (
                    oci.marketplace.models.ImageListingPackage,
                    oci.marketplace.models.pricing_model.PricingModel,
                    oci.marketplace.models.region.Region,
                    oci.marketplace.models.international_market_price.InternationalMarketPrice
            )):
                return obj.__dict__
            if isinstance(obj, datetime.datetime):
                return obj.isoformat()
            raise TypeError(f"Type {type(obj)} not serializable")

        with open(filename, 'w') as json_file:
            json.dump(self.final_listings, json_file, indent=4, default=serialize)
ftnt_marketplace = FTNTMarketplace()