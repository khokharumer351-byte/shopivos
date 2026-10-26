




insert into public.categories (name, image_url) values
  ('Tops',        'https://picsum.photos/seed/shopivo-cat-tops/600/600'),
  ('Bottoms',     'https://picsum.photos/seed/shopivo-cat-bottoms/600/600'),
  ('Outerwear',   'https://picsum.photos/seed/shopivo-cat-outer/600/600'),
  ('Sneakers',    'https://picsum.photos/seed/shopivo-cat-sneakers/600/600'),
  ('Accessories', 'https://picsum.photos/seed/shopivo-cat-acc/600/600')
on conflict (name) do nothing;

insert into public.products (name, description, price, compare_at_price, stock, category_id, images, sizes, is_featured)
select v.name, v.description, v.price, v.compare_at, v.stock, c.id, v.images, v.sizes, v.featured
from (values
  ('Cloud Puffer Jacket',
   'Oversized, ultra-light puffer with a matte finish. Warm enough for winter, chill enough for every day.',
   89.00, 120.00, 14, 'Outerwear',
   array['https://picsum.photos/seed/shopivo-puffer/800/1000', 'https://picsum.photos/seed/shopivo-puffer-2/800/1000'],
   array['S', 'M', 'L', 'XL'], true),
  ('Vintage Wash Tee',
   'Heavyweight 240gsm cotton with a sun-faded vintage wash and boxy fit.',
   29.00, null, 40, 'Tops',
   array['https://picsum.photos/seed/shopivo-tee/800/1000'],
   array['XS', 'S', 'M', 'L', 'XL'], true),
  ('Y2K Baby Tee',
   'Cropped, stretchy, and very early-2000s. Pairs with literally everything.',
   24.00, 32.00, 3, 'Tops',
   array['https://picsum.photos/seed/shopivo-babytee/800/1000'],
   array['XS', 'S', 'M'], false),
  ('Wide Leg Cargo Pants',
   'Relaxed wide-leg cargos with six pockets and adjustable toggles at the hem.',
   64.00, null, 22, 'Bottoms',
   array['https://picsum.photos/seed/shopivo-cargo/800/1000'],
   array['28', '30', '32', '34', '36'], true),
  ('Baggy Denim',
   'Mid-blue, rigid denim cut in a 90s baggy silhouette.',
   72.00, 90.00, 18, 'Bottoms',
   array['https://picsum.photos/seed/shopivo-denim/800/1000'],
   array['28', '30', '32', '34'], false),
  ('Retro Court Sneakers',
   'Leather low-tops inspired by 80s courts. Cushioned insole, gum sole.',
   110.00, null, 12, 'Sneakers',
   array['https://picsum.photos/seed/shopivo-sneaker/800/1000', 'https://picsum.photos/seed/shopivo-sneaker-2/800/1000'],
   array['38', '39', '40', '41', '42', '43', '44'], true),
  ('Chunky Runner',
   'Statement dad-shoe with layered mesh and a sculpted sole.',
   129.00, 150.00, 6, 'Sneakers',
   array['https://picsum.photos/seed/shopivo-runner/800/1000'],
   array['39', '40', '41', '42', '43'], false),
  ('Canvas Tote Bag',
   'Heavy canvas tote with an inner zip pocket. Fits a laptop and your whole life.',
   19.00, null, 60, 'Accessories',
   array['https://picsum.photos/seed/shopivo-tote/800/1000'],
   array[]::text[], true),
  ('Silver Chain Necklace',
   'Stainless steel chunky chain. Tarnish-resistant, layer-friendly.',
   34.00, null, 25, 'Accessories',
   array['https://picsum.photos/seed/shopivo-chain/800/1000'],
   array[]::text[], false),
  ('Washed Bucket Hat',
   'Soft washed cotton bucket hat with a slightly floppy brim.',
   22.00, 28.00, 30, 'Accessories',
   array['https://picsum.photos/seed/shopivo-bucket/800/1000'],
   array[]::text[], false)
) as v(name, description, price, compare_at, stock, category, images, sizes, featured)
join public.categories c on c.name = v.category;
