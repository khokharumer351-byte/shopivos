update public.products set images = array[
  'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80'
] where name = 'Y2K Baby Tee';

update public.products set images = array[
  'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=900&q=80'
] where name = 'Wide Leg Cargo Pants';

update public.products set images = array[
  'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=900&q=80'
] where name = 'Baggy Denim';

update public.products set images = array[
  'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=80'
] where name = 'Retro Court Sneakers';

update public.products set images = array[
  'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=900&q=80'
] where name = 'Chunky Runner';

update public.products set images = array[
  'https://images.unsplash.com/photo-1594223274512-ad4803739b7c?auto=format&fit=crop&w=900&q=80'
] where name = 'Canvas Tote Bag';

update public.products set images = array[
  'https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=900&q=80'
] where name = 'Silver Chain Necklace';

update public.products set images = array[
  'https://images.unsplash.com/photo-1521369909029-2afed882baee?auto=format&fit=crop&w=900&q=80'
] where name = 'Washed Bucket Hat';

update public.products set images = array[
  'https://images.unsplash.com/photo-1544923246-77307dd654cb?auto=format&fit=crop&w=900&q=80'
] where name = 'Cloud Puffer Jacket';

update public.products set images = array[
  'https://images.unsplash.com/photo-1503341504253-dff4815485f1?auto=format&fit=crop&w=900&q=80'
] where name = 'Vintage Wash Tee';

update public.categories set image_url = 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80'
  where name = 'Tops';
update public.categories set image_url = 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=900&q=80'
  where name = 'Bottoms';
update public.categories set image_url = 'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=900&q=80'
  where name = 'Outerwear';
update public.categories set image_url = 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80'
  where name = 'Sneakers';
update public.categories set image_url = 'https://images.unsplash.com/photo-1594223274512-ad4803739b7c?auto=format&fit=crop&w=900&q=80'
  where name = 'Accessories';

select name, images from public.products order by name;
