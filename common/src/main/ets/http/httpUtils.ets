import http from '@ohos.net.http';
import { commonStorage } from '../../../../Index';
import { StorageConst } from '../manager';
import { ResponseResult } from './response';
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { BASE_URL } from '../../../../BuildProfile';

export function requestApiCall(url: string,
  method: http.RequestMethod,
  data?: Record<string, number | boolean | string | Object | undefined>,
  headers?: Record<string, string>,
): Promise<ResponseResult> {
  const httpRequest = http.createHttp();
  const defaultHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
  }
  const token = commonStorage.getStringValueSync(StorageConst.TOKEN, "")
  console.log('[httpUtils] Token from storage:', token ? `${token.substring(0, 20)}...` : 'EMPTY')
  if (token) {
    defaultHeaders['Authorization'] = `Bearer ${token}`
    console.log('[httpUtils] Authorization header added')
  } else {
    console.warn('[httpUtils] No token found in storage')
  }

  const finalHeaders: Record<string, string> = {};
  Object.keys(defaultHeaders).forEach(key => {
    finalHeaders[key] = defaultHeaders[key];
  });
  if (headers) {
    Object.keys(headers).forEach(key => {
      finalHeaders[key] = String(headers[key]);
    });
  }

  let responseResult = httpRequest.request(BASE_URL + url, {
    method: method,
    extraData: data ? JSON.stringify(data) : undefined,
    header: finalHeaders,
    connectTimeout: 15000
  });
  let response: ResponseResult = new ResponseResult();
  return responseResult.then((value: http.HttpResponse) => {
    console.log('[httpUtils] HTTP status:', value.responseCode, 'URL:', BASE_URL + url);
    if (value.responseCode === 200) {
      let res: ResponseResult = JSON.parse(`${value.result}`);
      console.log('[httpUtils] Response code:', res.code, 'message:', res.message)
      response.data = res.data;
      response.code = res.code;
      response.message = res.message;
      if (res.code === 401 || (res.message && res.message.includes('token is expired'))) {
        console.warn('[httpUtils] Token expired or unauthorized, redirecting to login');
        commonStorage.deleteValueSync(StorageConst.TOKEN)
        commonStorage.deleteValueSync(StorageConst.USER_INFO)

        // 跳转到登录页面
        router.clear();
        router.replaceUrl({ url: 'pages/LoginPage' })
      }
    } else if (value.responseCode === 401) {
      // HTTP 401 - 未授权
      console.error('[httpUtils] HTTP 401 Unauthorized');
      response.message = '未授权，请重新登录';
      response.code = 401;
      // 清除 token 并跳转登录
      commonStorage.deleteValueSync(StorageConst.TOKEN)
      commonStorage.deleteValueSync(StorageConst.USER_INFO)
      router.clear();
      router.replaceUrl({ url: 'pages/LoginPage' })
    } else {
      let res: ResponseResult = JSON.parse(`${value.result}`);
      console.error('[httpUtils] HTTP error:', value.responseCode);
      response.message = res.message || '请求错误';
      response.code = res.code || 500;
    }
    return response;
  }).catch((error: BusinessError) => {
    console.log('httpUtils error', JSON.stringify(error))
    response.message = error.message;
    response.code = error.code;
    return response;
  })
}