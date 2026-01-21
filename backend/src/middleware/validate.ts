import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';

export const validateRequest = (schema: AnyZodObject) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const message = error.errors[0]?.message || 'البيانات غير صالحة';
        res.status(400).json({
          error: {
            message,
            code: 'BAD_REQUEST',
          },
        });
        return;
      }
      next(error);
    }
  };
};
