import { Response } from 'express';

type SuccessPayload<T> = {
  data: T;
  meta?: Record<string, unknown>;
};

export const sendSuccess = <T>(
  res: Response,
  data: T,
  status = 200,
  meta?: Record<string, unknown>
) => {
  const payload: SuccessPayload<T> = { data };
  if (meta && Object.keys(meta).length > 0) {
    payload.meta = meta;
  }
  return res.status(status).json({
    success: payload,
  });
};
