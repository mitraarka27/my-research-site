// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const projects = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.union([z.string(), z.date()]),
    status: z.enum(['past', 'ongoing']),
    tags: z.array(z.string()),
    cover: z.string().optional(),
    coverCaption: z.string().optional(),   // ⬅️ Add this line
    links: z.array(z.object({
      label: z.string(),
      href: z.string().url(),
    })).optional(),
    abstract: z.string().optional(),
  }),
});

export const collections = { projects };

