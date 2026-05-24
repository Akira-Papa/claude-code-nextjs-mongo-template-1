// examples/aggregation-pipeline.ts
// 集計パイプラインの参照実装。
// ポイント: $match/$project を最前段に置く / $lookup は絞ってから / 必要列だけ。

import { z } from 'zod';
import { PostModel } from '@/models/post';

const RangeInput = z.object({
  days: z.number().int().min(1).max(365).default(30),
  limit: z.number().int().min(1).max(100).default(20),
});

export type AuthorPostCount = {
  count: number;
  author: { name: string }[];
};

export async function topAuthorsByRecentPosts(input: unknown): Promise<AuthorPostCount[]> {
  const { days, limit } = RangeInput.parse(input); // 入力を型強制
  const since = new Date(Date.now() - days * 864e5);

  const rows = await PostModel.aggregate<AuthorPostCount>([
    { $match: { createdAt: { $gte: since } } }, // 先に絞る(インデックスが効く)
    { $group: { _id: '$authorId', count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: limit }, // 結合前に件数を絞る
    {
      $lookup: {
        from: 'users',
        localField: '_id',
        foreignField: '_id',
        as: 'author',
      },
    },
    { $project: { _id: 0, count: 1, 'author.name': 1 } }, // 必要列だけ
  ]);

  return rows;
}
