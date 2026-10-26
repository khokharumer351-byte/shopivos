








update public.products set images = array[
  'https://fakestoreapi.com/img/61pHAEJ4NML._AC_UX679_t.png'
] where name = 'Y2K Baby Tee';

update public.products set images = array[
  'https://upload.wikimedia.org/wikipedia/commons/c/cd/Cargo_pants_001.jpg'
] where name = 'Wide Leg Cargo Pants';

update public.products set images = array[
  'https://cdn.stocksnap.io/img-thumbs/960w/BCRQWOTPWM.jpg'
] where name = 'Baggy Denim';

update public.products set images = array[
  'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/1.webp',
  'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/2.webp'
] where name = 'Retro Court Sneakers';

update public.products set images = array[
  'https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/1.webp',
  'https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/2.webp'
] where name = 'Chunky Runner';

update public.products set images = array[
  'https://upload.wikimedia.org/wikipedia/commons/3/36/Cebu_Tote_Bag.jpg'
] where name = 'Canvas Tote Bag';

update public.products set images = array[
  'https://cdn.stocksnap.io/img-thumbs/960w/B3FWPBJURM.jpg'
] where name = 'Silver Chain Necklace';

update public.products set images = array[
  'https://upload.wikimedia.org/wikipedia/commons/3/32/Polo_Bucket_Hat.jpg'
] where name = 'Washed Bucket Hat';

update public.products set images = array[
  'https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_t.png'
] where name = 'Cloud Puffer Jacket';

update public.products set images = array[
  'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_t.png'
] where name = 'Vintage Wash Tee';


update public.categories set image_url = 'https://fakestoreapi.com/img/61pHAEJ4NML._AC_UX679_t.png'
  where name = 'Tops';
update public.categories set image_url = 'https://cdn.stocksnap.io/img-thumbs/960w/BCRQWOTPWM.jpg'
  where name = 'Bottoms';
update public.categories set image_url = 'https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_t.png'
  where name = 'Outerwear';
update public.categories set image_url = 'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/1.webp'
  where name = 'Sneakers';
update public.categories set image_url = 'https://cdn.stocksnap.io/img-thumbs/960w/B3FWPBJURM.jpg'
  where name = 'Accessories';


select name, images from public.products order by name;
