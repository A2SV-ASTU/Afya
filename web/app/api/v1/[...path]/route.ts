import { NextRequest, NextResponse } from 'next/server';

const BACKEND = process.env.API_BASE_URL ?? 'https://afya-c1ez.onrender.com';

async function proxy(req: NextRequest, ctx: { params: Promise<{ path: string[] }> }) {
  const { path } = await ctx.params;
  const target = `${BACKEND}/api/v1/${path.join('/')}${req.nextUrl.search}`;
  const secure = req.nextUrl.protocol === 'https:';

  const headers = new Headers();
  const cookie = req.headers.get('cookie');
  if (cookie) headers.set('cookie', cookie);

  const contentType = req.headers.get('content-type');
  if (contentType) headers.set('content-type', contentType);

  const role = req.headers.get('x-user-role');
  if (role) headers.set('x-user-role', role);

  const init: RequestInit = {
    method: req.method,
    headers,
    redirect: 'manual',
  };

  if (req.method !== 'GET' && req.method !== 'HEAD') {
    init.body = await req.arrayBuffer();
  }

  const upstream = await fetch(target, init);

  const responseHeaders = new Headers();
  upstream.headers.forEach((value, key) => {
    const lower = key.toLowerCase();
    if (
      lower === 'set-cookie' ||
      lower === 'transfer-encoding' ||
      lower === 'content-encoding'
    ) {
      return;
    }
    responseHeaders.append(key, value);
  });

  const res = new NextResponse(upstream.body, {
    status: upstream.status,
    headers: responseHeaders,
  });

  const setCookies =
    typeof upstream.headers.getSetCookie === 'function'
      ? upstream.headers.getSetCookie()
      : [];

  for (const cookieValue of setCookies) {
    res.headers.append('set-cookie', rewriteSetCookie(cookieValue, secure));
  }

  return res;
}

function rewriteSetCookie(cookie: string, secure: boolean): string {
  let rewritten = cookie.replace(/;\s*Domain=[^;]*/i, '');
  if (!secure) {
    rewritten = rewritten.replace(/;\s*Secure/gi, '');
    rewritten = rewritten.replace(/;\s*SameSite=None/gi, '; SameSite=Lax');
  }
  return rewritten;
}

export const GET = proxy;
export const POST = proxy;
export const PUT = proxy;
export const PATCH = proxy;
export const DELETE = proxy;
