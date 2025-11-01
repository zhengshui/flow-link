import { requestApiCall, Apis, toast } from "@tbs/common";
import { http } from "@kit.NetworkKit";
import { ChargeListData, OrderTypeData, PileListData, PriceListData, PileType, PriceType } from "../model/ChargeModel";
import { BusinessError } from "@kit.BasicServicesKit";
import { ResponseResult } from "@tbs/common/src/main/ets/http/response";
// 导入 Mock 数据
import {
  mockGetStations,
  mockGetPiles,
  mockGetChargePrice,
  mockStartCharge,
  mockStopCharge,
  mockGetChargeOrders
} from '../mock/ChargeMockData';

//获取充电站
export function getStations(name: string, pageNo: number = 1, pageSize: number = 20): Promise<ChargeListData | undefined> {
  // 使用 Mock 数据替代真实接口调用
  // return requestApiCall(`${Apis.CHARGE_STATION_LIST}?name=${name}&pageNo=${pageNo}&pageSize=${pageSize}`,
  //   http.RequestMethod.GET).then(res => {
  return mockGetStations(name, pageNo, pageSize).then((res: ResponseResult) => {
    if (res.code !== 0 && res.message) {
      toast(res.message)
    }
    const data = res.data as ChargeListData
    return data
  }).catch((err: BusinessError) => {
    console.error(`lucy++ 获取充电站接口调用失败，${err.code}+${err.message}`)
    return undefined
  })
}

//获取充电桩
export function getPiles(stationId: number): Promise<PileType[] | undefined> {
  // 使用 Mock 数据替代真实接口调用
  // return requestApiCall(`${Apis.CHARGE_PILE_LIST}?stationId=${stationId}`, http.RequestMethod.GET).then(res => {
  return mockGetPiles(stationId).then((res: ResponseResult) => {
    if (res.code !== 0 && res.message) {
      toast(res.message)
    }
    const data = res.data as PileListData
    return data.List
  }).catch((err: BusinessError) => {
    console.error(`lucy++ 获取充电桩接口调用失败，${err.code}+${err.message}`)
    return undefined
  })
}

//获取充电价格
export function getChargePrice(pageNo: number = 1, pageSize: number = 20): Promise<PriceType[] | undefined> {
  // 使用 Mock 数据替代真实接口调用
  // return requestApiCall(`${Apis.CHARGE_PRICE}?pageNo=${pageNo}&pageSize=${pageSize}`, http.RequestMethod.GET)
  //   .then(res => {
  return mockGetChargePrice(pageNo, pageSize).then((res: ResponseResult) => {
      console.log('lucy++ msg',res.message)
      if (res.code !== 0 && res.message) {
        toast(res.message)
      }
      const data = res.data as PriceListData
      return data.List
    }).catch((err: BusinessError) => {
      console.error(`lucy++ 获取充电价格接口调用失败，${err.code}+${err.message}`)
      return undefined
    })
}

//开始充电
export function getStartCharge(pileId: number): Promise<number | undefined> {
  // 使用 Mock 数据替代真实接口调用
  // const params: Record<string, Object> = {
  //   "pileId": pileId
  // }
  // return requestApiCall(Apis.CHARGE_START, http.RequestMethod.POST, params).then(res => {
  return mockStartCharge(pileId).then((res: ResponseResult) => {
    if (res.code !== 0 && res.message) {
      toast(res.message)
    }
    return res.code
  }).catch((err: BusinessError) => {
    console.error(`lucy++ 开始充电接口调用失败，${err.code}+${err.message}`)
    return undefined
  })
}

//获取充电订单列表
export function getChargeOrders(pageNo: number, pageSize: number): Promise<OrderTypeData | undefined> {
  // 使用 Mock 数据替代真实接口调用
  // return requestApiCall(`${Apis.CHARGE_ORDER_LIST}?pageNo=${pageNo}&pageSize=${pageSize}`, http.RequestMethod.GET)
  //   .then(res => {
  return mockGetChargeOrders(pageNo, pageSize).then((res: ResponseResult) => {
      if (res.code !== 0 && res.message) {
        toast(res.message)
      }
      const data = res.data as OrderTypeData
      return data
    }).catch((err: BusinessError) => {
      console.error(`lucy++ 获取充电订单列表接口调用失败，${err.code}+${err.message}`)
      return undefined
    })
}

//结束充电
export function getStopCharge(orderId: number): Promise<number | undefined> {
  // 使用 Mock 数据替代真实接口调用
  // const params: Record<string, Object> = {
  //   "orderId": orderId
  // }
  // return requestApiCall(Apis.CHARGE_STOP, http.RequestMethod.POST, params).then(res => {
  return mockStopCharge(orderId).then((res: ResponseResult) => {
    if (res.code !== 0 && res.message) {
      toast(res.message)
    }
    return res.code
  }).catch((err: BusinessError) => {
    console.error(`lucy++ 结束充电接口调用失败，${err.code}+${err.message}`)
    return undefined
  })
}