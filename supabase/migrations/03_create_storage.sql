-- 1. Create a new storage bucket for avatars
insert into storage.buckets (id, name, public) 
values ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Allow public access to view avatars
create policy "Avatar images are publicly accessible." 
on storage.objects for select 
using ( bucket_id = 'avatars' );

-- 3. Allow authenticated users to upload avatars
create policy "Anyone can upload an avatar." 
on storage.objects for insert 
with check ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );

-- 4. Allow users to update their own avatars
create policy "Users can update their own avatars."
on storage.objects for update
using ( bucket_id = 'avatars' AND auth.uid() = owner )
with check ( bucket_id = 'avatars' AND auth.uid() = owner );

-- 5. Allow users to delete their own avatars
create policy "Users can delete their own avatars."
on storage.objects for delete
using ( bucket_id = 'avatars' AND auth.uid() = owner );
