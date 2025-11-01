/**
 * 充电模块 Mock 数据文件
 * 用于替代真实的API接口调用，提供模拟数据
 */

import { ResponseResult } from "@tbs/common/src/main/ets/http/response";
import {
  ChargeListData,
  ChargeType,
  PileListData,
  PileType,
  PriceListData,
  PriceType,
  OrderTypeData,
  OrderType,
  StartChargeResult,
  StopChargeResult
} from '../model/ChargeModel';

/**
 * 模拟异步请求延迟
 * @param ms 延迟毫秒数，默认500ms
 */
async function mockDelay(ms: number = 500): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout((): void => {
      resolve();
    }, ms);
  });
}

/**
 * 辅助函数：字符串补齐
 */
function padStart(str: string, targetLength: number, padString: string): string {
  let result: string = str;
  while (result.length < targetLength) {
    result = padString + result;
  }
  return result;
}

/**
 * 20个充电站的完整 Mock 数据
 */
const MOCK_CHARGE_STATIONS: ChargeType[] = [
  {
    id: 1,
    name: '北京国贸CBD充电站',
    address: '北京市朝阳区建国门外大街1号国贸商城地下停车场',
    coordinate: '116.459984,39.908598',
    distance: 1.2,
    pileTotal: 8,
    freePileTotal: 3,
    pricePerHour: 1.8,
    imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=CBD',
    tenantId: 1001,
    tenantName: '北京充电科技有限公司'
  },
  {
    id: 2,
    name: '上海陆家嘴金融中心充电站',
    address: '上海市浦东新区世纪大道88号金茂大厦地下车库',
    coordinate: '121.505544,31.243107',
    distance: 0.8,
    pileTotal: 12,
    freePileTotal: 5,
    pricePerHour: 2.0,
    imageUrl: 'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Lujiazui',
    tenantId: 1002,
    tenantName: '上海电动出行有限公司'
  },
  {
    id: 3,
    name: '深圳科技园超级充电站',
    address: '广东省深圳市南山区高新科技园南区科苑路15号',
    coordinate: '113.952325,22.535524',
    distance: 2.5,
    pileTotal: 16,
    freePileTotal: 8,
    pricePerHour: 1.6,
    imageUrl: 'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=TechPark',
    tenantId: 1003,
    tenantName: '深圳绿色出行服务公司'
  },
  {
    id: 4,
    name: '广州天河城购物中心充电站',
    address: '广东省广州市天河区天河路208号天河城B2层停车场',
    coordinate: '113.331284,23.136408',
    distance: 3.2,
    pileTotal: 10,
    freePileTotal: 2,
    pricePerHour: 1.9,
    imageUrl: 'https://via.placeholder.com/400x300/E91E63/FFFFFF?text=Teemall',
    tenantId: 1001,
    tenantName: '北京充电科技有限公司'
  },
  {
    id: 5,
    name: '杭州西湖文化广场充电站',
    address: '浙江省杭州市下城区中山北路218号文化广场地下停车场',
    coordinate: '120.164622,30.281511',
    distance: 1.5,
    pileTotal: 6,
    freePileTotal: 4,
    pricePerHour: 1.7,
    imageUrl: 'https://via.placeholder.com/400x300/9C27B0/FFFFFF?text=Xihu',
    tenantId: 1004,
    tenantName: '杭州智慧充电运营公司'
  },
  {
    id: 6,
    name: '成都春熙路商圈充电站',
    address: '四川省成都市锦江区红星路三段99号银石广场停车场',
    coordinate: '104.083042,30.658275',
    distance: 4.1,
    pileTotal: 8,
    freePileTotal: 1,
    pricePerHour: 1.5,
    imageUrl: 'https://via.placeholder.com/400x300/3F51B5/FFFFFF?text=Chunxi',
    tenantId: 1005,
    tenantName: '成都新能源充电服务公司'
  },
  {
    id: 7,
    name: '南京新街口中心充电站',
    address: '江苏省南京市玄武区中山东路18号德基广场地下停车场',
    coordinate: '118.778990,32.046170',
    distance: 2.8,
    pileTotal: 10,
    freePileTotal: 6,
    pricePerHour: 1.8,
    imageUrl: 'https://via.placeholder.com/400x300/00BCD4/FFFFFF?text=Xinjiekou',
    tenantId: 1002,
    tenantName: '上海电动出行有限公司'
  },
  {
    id: 8,
    name: '武汉光谷广场充电站',
    address: '湖北省武汉市洪山区珞喻路889号光谷国际广场停车场',
    coordinate: '114.418885,30.476173',
    distance: 5.3,
    pileTotal: 12,
    freePileTotal: 7,
    pricePerHour: 1.6,
    imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Guanggu',
    tenantId: 1003,
    tenantName: '深圳绿色出行服务公司'
  },
  {
    id: 9,
    name: '西安钟楼商业区充电站',
    address: '陕西省西安市碑林区东大街1号世纪金花地下停车场',
    coordinate: '108.950974,34.260204',
    distance: 1.9,
    pileTotal: 7,
    freePileTotal: 3,
    pricePerHour: 1.5,
    imageUrl: 'https://via.placeholder.com/400x300/FF5722/FFFFFF?text=Zhonglou',
    tenantId: 1006,
    tenantName: '西安电力充电运营公司'
  },
  {
    id: 10,
    name: '重庆解放碑步行街充电站',
    address: '重庆市渝中区解放碑步行街88号时代广场地下车库',
    coordinate: '106.578636,29.559299',
    distance: 3.7,
    pileTotal: 9,
    freePileTotal: 4,
    pricePerHour: 1.7,
    imageUrl: 'https://via.placeholder.com/400x300/795548/FFFFFF?text=Jiefangbei',
    tenantId: 1005,
    tenantName: '成都新能源充电服务公司'
  },
  {
    id: 11,
    name: '天津滨江道商业街充电站',
    address: '天津市和平区滨江道188号恒隆广场地下停车场',
    coordinate: '117.195907,39.118327',
    distance: 2.3,
    pileTotal: 8,
    freePileTotal: 5,
    pricePerHour: 1.8,
    imageUrl: 'https://via.placeholder.com/400x300/607D8B/FFFFFF?text=Binjiang',
    tenantId: 1001,
    tenantName: '北京充电科技有限公司'
  },
  {
    id: 12,
    name: '苏州工业园区充电站',
    address: '江苏省苏州市工业园区苏州中心广场B2停车场',
    coordinate: '120.697763,31.316439',
    distance: 6.2,
    pileTotal: 14,
    freePileTotal: 9,
    pricePerHour: 1.6,
    imageUrl: 'https://via.placeholder.com/400x300/009688/FFFFFF?text=SIP',
    tenantId: 1007,
    tenantName: '苏州智慧能源有限公司'
  },
  {
    id: 13,
    name: '厦门SM城市广场充电站',
    address: '福建省厦门市思明区仙岳路SM城市广场地下停车场',
    coordinate: '118.103886,24.489231',
    distance: 4.5,
    pileTotal: 10,
    freePileTotal: 3,
    pricePerHour: 1.9,
    imageUrl: 'https://via.placeholder.com/400x300/CDDC39/FFFFFF?text=SM',
    tenantId: 1008,
    tenantName: '厦门绿色充电网络公司'
  },
  {
    id: 14,
    name: '青岛五四广场充电站',
    address: '山东省青岛市市南区东海西路51号五四广场地下车库',
    coordinate: '120.391382,36.061059',
    distance: 1.6,
    pileTotal: 6,
    freePileTotal: 2,
    pricePerHour: 1.7,
    imageUrl: 'https://via.placeholder.com/400x300/FFC107/FFFFFF?text=Wusi',
    tenantId: 1009,
    tenantName: '青岛海洋充电科技公司'
  },
  {
    id: 15,
    name: '长沙五一广场充电站',
    address: '湖南省长沙市芙蓉区五一大道188号平和堂地下停车场',
    coordinate: '112.982951,28.195806',
    distance: 3.4,
    pileTotal: 8,
    freePileTotal: 4,
    pricePerHour: 1.5,
    imageUrl: 'https://via.placeholder.com/400x300/8BC34A/FFFFFF?text=Wuyi',
    tenantId: 1010,
    tenantName: '长沙星城充电运营公司'
  },
  {
    id: 16,
    name: '郑州二七广场充电站',
    address: '河南省郑州市二七区二七路230号德化步行街停车场',
    coordinate: '113.650955,34.749069',
    distance: 2.1,
    pileTotal: 7,
    freePileTotal: 3,
    pricePerHour: 1.6,
    imageUrl: 'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Erqi',
    tenantId: 1006,
    tenantName: '西安电力充电运营公司'
  },
  {
    id: 17,
    name: '沈阳中街商业圈充电站',
    address: '辽宁省沈阳市沈河区中街路212号兴隆大家庭地下车库',
    coordinate: '123.461440,41.798079',
    distance: 5.8,
    pileTotal: 9,
    freePileTotal: 5,
    pricePerHour: 1.8,
    imageUrl: 'https://via.placeholder.com/400x300/673AB7/FFFFFF?text=Zhongjie',
    tenantId: 1011,
    tenantName: '沈阳北方充电网络公司'
  },
  {
    id: 18,
    name: '大连星海广场充电站',
    address: '辽宁省大连市沙河口区中山路572号星海广场地下停车场',
    coordinate: '121.607445,38.912781',
    distance: 7.2,
    pileTotal: 11,
    freePileTotal: 6,
    pricePerHour: 1.7,
    imageUrl: 'https://via.placeholder.com/400x300/03A9F4/FFFFFF?text=Xinghai',
    tenantId: 1011,
    tenantName: '沈阳北方充电网络公司'
  },
  {
    id: 19,
    name: '昆明金马碧鸡坊充电站',
    address: '云南省昆明市五华区金碧路168号南屏步行街停车场',
    coordinate: '102.711301,25.041988',
    distance: 4.8,
    pileTotal: 8,
    freePileTotal: 4,
    pricePerHour: 1.5,
    imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Jinma',
    tenantId: 1012,
    tenantName: '昆明春城充电服务公司'
  },
  {
    id: 20,
    name: '合肥天鹅湖万达充电站',
    address: '安徽省合肥市政务区怀宁路与石台路交口万达广场停车场',
    coordinate: '117.226371,31.821426',
    distance: 3.9,
    pileTotal: 10,
    freePileTotal: 7,
    pricePerHour: 1.6,
    imageUrl: 'https://via.placeholder.com/400x300/9E9E9E/FFFFFF?text=Wanda',
    tenantId: 1013,
    tenantName: '合肥庐州充电运营公司'
  }
];

/**
 * 充电桩数据 - 使用 Record 代替 Map
 */
function getPilesForStation(stationId: number): PileType[] {
  // 站点1的充电桩
  if (stationId === 1) {
    return [
      { id: 101, code: 'BJ-CBD-001', stationId: 1, stationName: '北京国贸CBD充电站', state: 0 },
      { id: 102, code: 'BJ-CBD-002', stationId: 1, stationName: '北京国贸CBD充电站', state: 1 },
      { id: 103, code: 'BJ-CBD-003', stationId: 1, stationName: '北京国贸CBD充电站', state: 0 },
      { id: 104, code: 'BJ-CBD-004', stationId: 1, stationName: '北京国贸CBD充电站', state: 1 },
      { id: 105, code: 'BJ-CBD-005', stationId: 1, stationName: '北京国贸CBD充电站', state: 0 },
      { id: 106, code: 'BJ-CBD-006', stationId: 1, stationName: '北京国贸CBD充电站', state: 1 },
      { id: 107, code: 'BJ-CBD-007', stationId: 1, stationName: '北京国贸CBD充电站', state: 1 },
      { id: 108, code: 'BJ-CBD-008', stationId: 1, stationName: '北京国贸CBD充电站', state: 1 }
    ];
  }
  // 站点2的充电桩
  if (stationId === 2) {
    return [
      { id: 201, code: 'SH-LJZ-001', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 0 },
      { id: 202, code: 'SH-LJZ-002', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 0 },
      { id: 203, code: 'SH-LJZ-003', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 1 },
      { id: 204, code: 'SH-LJZ-004', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 0 },
      { id: 205, code: 'SH-LJZ-005', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 1 },
      { id: 206, code: 'SH-LJZ-006', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 0 },
      { id: 207, code: 'SH-LJZ-007', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 1 },
      { id: 208, code: 'SH-LJZ-008', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 1 },
      { id: 209, code: 'SH-LJZ-009', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 0 },
      { id: 210, code: 'SH-LJZ-010', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 1 },
      { id: 211, code: 'SH-LJZ-011', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 1 },
      { id: 212, code: 'SH-LJZ-012', stationId: 2, stationName: '上海陆家嘴金融中心充电站', state: 1 }
    ];
  }
  // 站点3的充电桩
  if (stationId === 3) {
    return [
      { id: 301, code: 'SZ-KJY-001', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 302, code: 'SZ-KJY-002', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 303, code: 'SZ-KJY-003', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 304, code: 'SZ-KJY-004', stationId: 3, stationName: '深圳科技园超级充电站', state: 1 },
      { id: 305, code: 'SZ-KJY-005', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 306, code: 'SZ-KJY-006', stationId: 3, stationName: '深圳科技园超级充电站', state: 1 },
      { id: 307, code: 'SZ-KJY-007', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 308, code: 'SZ-KJY-008', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 309, code: 'SZ-KJY-009', stationId: 3, stationName: '深圳科技园超级充电站', state: 1 },
      { id: 310, code: 'SZ-KJY-010', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 311, code: 'SZ-KJY-011', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 312, code: 'SZ-KJY-012', stationId: 3, stationName: '深圳科技园超级充电站', state: 1 },
      { id: 313, code: 'SZ-KJY-013', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 },
      { id: 314, code: 'SZ-KJY-014', stationId: 3, stationName: '深圳科技园超级充电站', state: 1 },
      { id: 315, code: 'SZ-KJY-015', stationId: 3, stationName: '深圳科技园超级充电站', state: 1 },
      { id: 316, code: 'SZ-KJY-016', stationId: 3, stationName: '深圳科技园超级充电站', state: 0 }
    ];
  }
  // 站点4的充电桩
  if (stationId === 4) {
    return [
      { id: 401, code: 'GZ-THC-001', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 },
      { id: 402, code: 'GZ-THC-002', stationId: 4, stationName: '广州天河城购物中心充电站', state: 0 },
      { id: 403, code: 'GZ-THC-003', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 },
      { id: 404, code: 'GZ-THC-004', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 },
      { id: 405, code: 'GZ-THC-005', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 },
      { id: 406, code: 'GZ-THC-006', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 },
      { id: 407, code: 'GZ-THC-007', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 },
      { id: 408, code: 'GZ-THC-008', stationId: 4, stationName: '广州天河城购物中心充电站', state: 0 },
      { id: 409, code: 'GZ-THC-009', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 },
      { id: 410, code: 'GZ-THC-010', stationId: 4, stationName: '广州天河城购物中心充电站', state: 1 }
    ];
  }
  // 站点5的充电桩
  if (stationId === 5) {
    return [
      { id: 501, code: 'HZ-XH-001', stationId: 5, stationName: '杭州西湖文化广场充电站', state: 0 },
      { id: 502, code: 'HZ-XH-002', stationId: 5, stationName: '杭州西湖文化广场充电站', state: 0 },
      { id: 503, code: 'HZ-XH-003', stationId: 5, stationName: '杭州西湖文化广场充电站', state: 1 },
      { id: 504, code: 'HZ-XH-004', stationId: 5, stationName: '杭州西湖文化广场充电站', state: 0 },
      { id: 505, code: 'HZ-XH-005', stationId: 5, stationName: '杭州西湖文化广场充电站', state: 1 },
      { id: 506, code: 'HZ-XH-006', stationId: 5, stationName: '杭州西湖文化广场充电站', state: 0 }
    ];
  }

  // 其他站点返回空数组
  return [];
}

/**
 * 充电价格数据 - 分时段定价
 */
const MOCK_CHARGE_PRICES: PriceType[] = [
  { id: 1, startHour: 0, endHour: 8, price: '1.2', tenantId: 1001 },
  { id: 2, startHour: 8, endHour: 12, price: '1.8', tenantId: 1001 },
  { id: 3, startHour: 12, endHour: 14, price: '2.0', tenantId: 1001 },
  { id: 4, startHour: 14, endHour: 18, price: '1.6', tenantId: 1001 },
  { id: 5, startHour: 18, endHour: 22, price: '2.2', tenantId: 1001 },
  { id: 6, startHour: 22, endHour: 24, price: '1.4', tenantId: 1001 }
];

/**
 * 充电订单数据
 */
const MOCK_CHARGE_ORDERS: OrderType[] = [
  {
    id: 1001,
    orderCode: 'ORD20250101001',
    pileCode: 'BJ-CBD-001',
    stationName: '北京国贸CBD充电站',
    startAt: '2025-01-01 08:30:00',
    stopAt: '2025-01-01 10:15:00',
    price: 58.5,
    state: 1
  },
  {
    id: 1002,
    orderCode: 'ORD20250101002',
    pileCode: 'SH-LJZ-003',
    stationName: '上海陆家嘴金融中心充电站',
    startAt: '2025-01-01 14:20:00',
    stopAt: '',
    price: 0,
    state: 0
  },
  {
    id: 1003,
    orderCode: 'ORD20250101003',
    pileCode: 'SZ-KJY-005',
    stationName: '深圳科技园超级充电站',
    startAt: '2024-12-31 18:45:00',
    stopAt: '2024-12-31 20:30:00',
    price: 72.8,
    state: 2
  },
  {
    id: 1004,
    orderCode: 'ORD20241230001',
    pileCode: 'GZ-THC-002',
    stationName: '广州天河城购物中心充电站',
    startAt: '2024-12-30 09:15:00',
    stopAt: '2024-12-30 11:00:00',
    price: 45.2,
    state: 1
  },
  {
    id: 1005,
    orderCode: 'ORD20241229001',
    pileCode: 'HZ-XH-001',
    stationName: '杭州西湖文化广场充电站',
    startAt: '2024-12-29 16:30:00',
    stopAt: '2024-12-29 18:20:00',
    price: 38.6,
    state: 1
  }
];

// 当前正在充电的订单ID（用于模拟充电状态）
let currentChargingOrderId: number = 1002;

/**
 * 获取充电站列表 Mock
 */
export async function mockGetStations(name: string, pageNo: number = 1, pageSize: number = 20): Promise<ResponseResult> {
  await mockDelay(600);

  // 根据名称过滤充电站
  let filteredStations: ChargeType[] = MOCK_CHARGE_STATIONS;
  if (name && name.trim() !== '') {
    const searchResults: ChargeType[] = [];
    for (let i: number = 0; i < MOCK_CHARGE_STATIONS.length; i++) {
      const station: ChargeType = MOCK_CHARGE_STATIONS[i];
      const stationName: string = station.name ?? '';
      const stationAddress: string = station.address ?? '';
      if (stationName.indexOf(name) !== -1 || stationAddress.indexOf(name) !== -1) {
        searchResults.push(station);
      }
    }
    filteredStations = searchResults;
  }

  // 分页处理
  const startIndex: number = (pageNo - 1) * pageSize;
  const endIndex: number = startIndex + pageSize;
  const paginatedStations: ChargeType[] = filteredStations.slice(startIndex, endIndex);

  const data: ChargeListData = {
    PageNo: pageNo,
    PageSize: pageSize,
    TotalCount: filteredStations.length,
    List: paginatedStations
  };

  return {
    code: 0,
    message: '获取成功',
    data: data
  };
}

/**
 * 获取充电桩列表 Mock
 */
export async function mockGetPiles(stationId: number): Promise<ResponseResult> {
  await mockDelay(400);

  // 获取指定站点的充电桩
  let piles: PileType[] = getPilesForStation(stationId);

  // 如果没有该站点的数据，动态生成
  if (piles.length === 0) {
    let station: ChargeType | undefined = undefined;
    for (let i: number = 0; i < MOCK_CHARGE_STATIONS.length; i++) {
      if (MOCK_CHARGE_STATIONS[i].id === stationId) {
        station = MOCK_CHARGE_STATIONS[i];
        break;
      }
    }

    if (station !== undefined && station.pileTotal !== undefined) {
      const stationName: string = station.name ?? '';
      const total: number = station.pileTotal;
      for (let i: number = 1; i <= total; i++) {
        const randomValue: number = Math.random();
        const state: number = randomValue > 0.6 ? 0 : 1;
        const codeNumber: string = padStart(i.toString(), 3, '0');
        piles.push({
          id: stationId * 100 + i,
          code: `PILE-${stationId}-${codeNumber}`,
          stationId: stationId,
          stationName: stationName,
          state: state
        });
      }
    }
  }

  const data: PileListData = {
    PageNo: 1,
    PageSize: 100,
    TotalCount: piles.length,
    List: piles
  };

  return {
    code: 0,
    message: '获取成功',
    data: data
  };
}

/**
 * 获取充电价格 Mock
 */
export async function mockGetChargePrice(pageNo: number = 1, pageSize: number = 20): Promise<ResponseResult> {
  await mockDelay(300);

  const data: PriceListData = {
    PageNo: pageNo,
    PageSize: pageSize,
    TotalCount: MOCK_CHARGE_PRICES.length,
    List: MOCK_CHARGE_PRICES
  };

  return {
    code: 0,
    message: '获取成功',
    data: data
  };
}

/**
 * 开始充电 Mock
 */
export async function mockStartCharge(pileId: number): Promise<ResponseResult> {
  await mockDelay(800);

  // 模拟充电桩忙碌的情况
  const randomValue: number = Math.random();
  if (randomValue > 0.9) {
    return {
      code: 3001,
      message: '充电桩正在使用中，请选择其他充电桩',
      data: undefined
    };
  }

  // 创建新的充电订单
  currentChargingOrderId++;
  const timestamp: number = Date.now();
  const currentDate: Date = new Date();
  const dateStr: string = currentDate.toLocaleString('zh-CN');

  const newOrder: OrderType = {
    id: currentChargingOrderId,
    orderCode: `ORD${timestamp}`,
    pileCode: `PILE-${pileId}`,
    stationName: '模拟充电站',
    startAt: dateStr,
    stopAt: '',
    price: 0,
    state: 0
  };
  MOCK_CHARGE_ORDERS.unshift(newOrder);
  const result: StartChargeResult = { orderId: currentChargingOrderId };
  return {
    code: 0,
    message: '开始充电成功',
    data: result
  };
}

/**
 * 结束充电 Mock
 */
export async function mockStopCharge(orderId: number): Promise<ResponseResult> {
  await mockDelay(700);

  // 查找订单
  let order: OrderType | undefined = undefined;
  for (let i: number = 0; i < MOCK_CHARGE_ORDERS.length; i++) {
    if (MOCK_CHARGE_ORDERS[i].id === orderId) {
      order = MOCK_CHARGE_ORDERS[i];
      break;
    }
  }

  if (order === undefined) {
    return {
      code: 4001,
      message: '订单不存在',
      data: undefined
    };
  }

  // 更新订单状态
  const currentDate: Date = new Date();
  const dateStr: string = currentDate.toLocaleString('zh-CN');
  order.stopAt = dateStr;
  order.state = 1;
  const randomPrice: number = Math.random() * 100 + 20;
  order.price = Number(randomPrice.toFixed(2));
  const result: StopChargeResult = { success: true };
  return {
    code: 0,
    message: '结束充电成功',
    data: result
  };
}

/**
 * 获取充电订单列表 Mock
 */
export async function mockGetChargeOrders(pageNo: number, pageSize: number): Promise<ResponseResult> {
  await mockDelay(500);

  // 分页处理
  const startIndex: number = (pageNo - 1) * pageSize;
  const endIndex: number = startIndex + pageSize;
  const paginatedOrders: OrderType[] = MOCK_CHARGE_ORDERS.slice(startIndex, endIndex);

  const data: OrderTypeData = {
    PageNo: pageNo,
    PageSize: pageSize,
    TotalCount: MOCK_CHARGE_ORDERS.length,
    List: paginatedOrders
  };

  return {
    code: 0,
    message: '获取成功',
    data: data
  };
}
