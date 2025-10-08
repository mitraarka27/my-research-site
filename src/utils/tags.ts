export const tagToSlug = (t: string) =>
  encodeURIComponent(
    t.trim().toLowerCase()
      .replace(/&/g, "and")
      .replace(/[\/]/g, "-")
      .replace(/\s+/g, "-")
      .replace(/[^a-z0-9\-]/g, "")
  );

export const slugToTag = (slug: string, allTags: string[]) => {
  const decoded = decodeURIComponent(slug);
  return allTags.find((t) => tagToSlug(t) === decoded) ?? decoded;
};

