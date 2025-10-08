// src/utils/tags.ts
export const tagToSlug = (t: string) =>
  encodeURIComponent(
    t.trim().toLowerCase()
      .replace(/&/g, 'and')
      .replace(/[\/]/g, '-')       // slashes → dashes
      .replace(/\s+/g, '-')        // spaces → dashes
      .replace(/[^a-z0-9\-]/g, '') // strip punctuation
  );

export const slugToTag = (slug: string, allTags: string[]) => {
  const decoded = decodeURIComponent(slug);
  return allTags.find(t => tagToSlug(t) === decoded) ?? decoded;
};
