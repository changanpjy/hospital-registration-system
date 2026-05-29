import type { AppointmentStatus, NavItem, Period, ScheduleStatus } from './types'

export const periodText: Record<Period, string> = { MORNING: '上午', AFTERNOON: '下午' }
export const statusText: Record<ScheduleStatus, string> = { AVAILABLE: '可预约', FULL: '已约满', STOPPED: '停诊' }
export const appointmentText: Record<AppointmentStatus, string> = { WAITING: '待就诊', CANCELLED: '已取消', COMPLETED: '已完成' }

export const navItems: NavItem[] = [
  { key: 'booking', label: '挂号预约' },
  { key: 'patients', label: '就诊人' },
  { key: 'appointments', label: '我的预约' },
  { key: 'profile', label: '个人中心' },
  { key: 'admin', label: '管理统计' },
  { key: 'userManagement', label: '用户管理' }
]
