import crypto from 'crypto';

export default function generateLocalToken() {
  return crypto.randomBytes(64).toString('hex');
}