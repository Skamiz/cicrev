
bucket.register_bucket(
	{ -- empty bucket
		item_name = "bucket:bucket_wood_empty",
		description = "Empty Wooden Bucket",
		inventory_image = "bucket_wood_empty.png",
		groups = {bucket = 1},
	},
	{ -- list of full buckets
		{
			liquid_source = "cicrev:water_source",
			item_name = "bucket:bucket_wood_water",
			description = "Water Bucket",
			inventory_image = "bucket_wood_water.png",
			groups = {water_bucket = 1},
		},
	}
)
