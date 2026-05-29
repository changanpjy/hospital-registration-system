export type Role = 'PATIENT' | 'ADMIN'
export type Period = 'MORNING' | 'AFTERNOON'
export type ScheduleStatus = 'AVAILABLE' | 'FULL' | 'STOPPED'
export type AppointmentStatus = 'WAITING' | 'CANCELLED' | 'COMPLETED'
export type NavKey = 'booking' | 'patients' | 'appointments' | 'profile' | 'admin' | 'userManagement'
export type ActivePage = NavKey | 'auth' | 'appointmentSuccess'
export type RegisterType = 'phone' | 'email'

export interface User {
  id: number
  username: string
  phone?: string | null
  email?: string | null
  role: Role
  status?: number | null
  createTime?: string | null
}

export interface RegisterForm {
  username: string
  phone: string
  email: string
  password: string
}

export interface ProfileForm {
  username: string
  phone: string
  email: string
}

export interface Patient {
  id: number
  userId: number
  name: string
  idCard: string
  phone: string
  gender?: number | null
  birthDate?: string | null
}

export interface PatientForm {
  name: string
  idCard: string
  phone: string
  gender: number
  birthDate: string
}

export interface Department {
  id: number
  name: string
  description?: string | null
}

export interface Doctor {
  id: number
  departmentId: number
  departmentName?: string
  name: string
  title: string
  specialty?: string | null
  introduction?: string | null
}

export interface Schedule {
  id: number
  doctorId: number
  doctorName?: string
  departmentId: number
  departmentName?: string
  workDate: string
  period: Period
  totalCount: number
  availableCount: number
  status: ScheduleStatus
}

export interface Appointment {
  id: number
  appointmentNo: string
  userId: number
  patientId: number
  patientName: string
  departmentId: number
  departmentName: string
  doctorId: number
  doctorName: string
  scheduleId: number
  visitDate: string
  period: Period
  status: AppointmentStatus
  noticeSent: number
  createTime?: string
}

export interface StatisticsRow {
  visitDate?: string
  departmentName?: string
  total: number
}

export interface Statistics {
  dailyAppointments?: StatisticsRow[]
  popularDepartments?: StatisticsRow[]
}

export interface ScheduleEdit {
  totalCount: number
  availableCount: number
  status: ScheduleStatus
}

export interface NavItem {
  key: NavKey
  label: string
}

export interface SearchResult {
  departments?: Department[]
  doctors?: Doctor[]
}
