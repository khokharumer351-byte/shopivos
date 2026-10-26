




insert into public.categories (name, image_url) values
  ('Tops',        'https://fakestoreapi.com/img/61pHAEJ4NML._AC_UX679_t.png'),
  ('Bottoms',     'https://cdn.stocksnap.io/img-thumbs/960w/BCRQWOTPWM.jpg'),
  ('Outerwear',   'https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_t.png'),
  ('Sneakers',    'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/1.webp'),
  ('Accessories', 'https://cdn.stocksnap.io/img-thumbs/960w/B3FWPBJURM.jpg')
on conflict (name) do nothing;

insert into public.products (name, description, price, compare_at_price, stock, category_id, images, sizes, is_featured)
select v.name, v.description, v.price, v.compare_at, v.stock, c.id, v.images, v.sizes, v.featured
from (values
  ('Cloud Puffer Jacket',
   'Oversized, ultra-light puffer with a matte finish. Warm enough for winter, chill enough for every day.',
   89.00, 120.00, 14, 'Outerwear',
   array['https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_t.png'],
   array['S', 'M', 'L', 'XL'], true),
  ('Vintage Wash Tee',
   'Heavyweight 240gsm cotton with a sun-faded vintage wash and boxy fit.',
   29.00, null, 40, 'Tops',
   array['https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_t.png'],
   array['XS', 'S', 'M', 'L', 'XL'], true),
  ('Y2K Baby Tee',
   'Cropped, stretchy, and very early-2000s. Pairs with literally everything.',
   24.00, 32.00, 3, 'Tops',
   array['https://fakestoreapi.com/img/61pHAEJ4NML._AC_UX679_t.png'],
   array['XS', 'S', 'M'], false),
  ('Wide Leg Cargo Pants',
   'Relaxed wide-leg cargos with six pockets and adjustable toggles at the hem.',
   64.00, null, 22, 'Bottoms',
   array['https://upload.wikimedia.org/wikipedia/commons/c/cd/Cargo_pants_001.jpg'],
   array['28', '30', '32', '34', '36'], true),
  ('Baggy Denim',
   'Mid-blue, rigid denim cut in a 90s baggy silhouette.',
   72.00, 90.00, 18, 'Bottoms',
   array['https://cdn.stocksnap.io/img-thumbs/960w/BCRQWOTPWM.jpg'],
   array['28', '30', '32', '34'], false),
  ('Retro Court Sneakers',
   'Leather low-tops inspired by 80s courts. Cushioned insole, gum sole.',
   110.00, null, 12, 'Sneakers',
   array['https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/1.webp', 'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/2.webp'],
   array['38', '39', '40', '41', '42', '43', '44'], true),
  ('Chunky Runner',
   'Statement dad-shoe with layered mesh and a sculpted sole.',
   129.00, 150.00, 6, 'Sneakers',
   array['https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/1.webp', 'https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/2.webp'],
   array['39', '40', '41', '42', '43'], false),
  ('Canvas Tote Bag',
   'Heavy canvas tote with an inner zip pocket. Fits a laptop and your whole life.',
   19.00, null, 60, 'Accessories',
   array['https://upload.wikimedia.org/wikipedia/commons/3/36/Cebu_Tote_Bag.jpg'],
   array[]::text[], true),
  ('Silver Chain Necklace',
   'Stainless steel chunky chain. Tarnish-resistant, layer-friendly.',
   34.00, null, 25, 'Accessories',
   array['https://cdn.stocksnap.io/img-thumbs/960w/B3FWPBJURM.jpg'],
   array[]::text[], false),
  ('Washed Bucket Hat',
   'Soft washed cotton bucket hat with a slightly floppy brim.',
   22.00, 28.00, 30, 'Accessories',
   array['https://upload.wikimedia.org/wikipedia/commons/3/32/Polo_Bucket_Hat.jpg'],
   array[]::text[], false)
) as v(name, description, price, compare_at, stock, category, images, sizes, featured)
join public.categories c on c.name = v.category;
