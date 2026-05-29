<template>
  <div class="app-shell">
    <aside class="sidebar">
      <div class="brand">
        <span class="brand-mark">医</span>
        <div>
          <strong>长安医院</strong>
          <small>门诊预约挂号平台</small>
        </div>
      </div>
      <nav>
        <button
          v-for="item in visibleNavItems"
          :key="item.key"
          type="button"
          :class="{ active: activePage === item.key }"
          @click="openPage(item.key)"
        >
          {{ item.label }}
        </button>
      </nav>
      <div class="service-card">
        <span>门诊服务热线</span>
        <strong>400-1234-5678</strong>
        <small class="service-time">
          <span>取号时间</span>
          <span>08:00-12:00</span>
          <span></span>
          <span>12:30-17:30</span>
        </small>
      </div>
    </aside>

    <main class="main">
      <header v-if="activePage !== 'auth'" class="topbar">
        <div class="topbar-title">
          <span>门诊挂号工作台</span>
          <strong>{{ activeNav?.label }}</strong>
        </div>
        <div class="topbar-meta">
          <span>{{ todayText }}</span>
        </div>
        <div v-if="user" class="account">
          <span class="avatar">{{ user.username.slice(0, 1).toUpperCase() }}</span>
          <span>{{ user.username }}</span>
          <button class="ghost" type="button" @click="logout">退出</button>
        </div>
        <div v-else class="auth-actions">
          <button type="button" @click="openAuth('login')">登录</button>
          <button class="ghost" type="button" @click="openAuth('register')">注册</button>
        </div>
      </header>

      <div v-if="message" class="toast">{{ message }}</div>

      <BookingView
        v-if="activePage === 'booking'"
        :departments="departments"
        :doctors="doctors"
        :schedules="schedules"
        :search-doctors="searchDoctors"
        :patients="patients"
        :selected-department="selectedDepartment"
        :selected-doctor="selectedDoctor"
        :selected-schedule="selectedSchedule"
        :selected-patient-id="selectedPatientId"
        :can-submit="Boolean(user && selectedSchedule && selectedPatientId)"
        :keyword="keyword"
        @update:selected-patient-id="selectedPatientId = $event"
        @update:selected-schedule="selectedSchedule = $event"
        @update:keyword="updateKeyword"
        @load-doctors="loadDoctorsWithGuard"
        @load-schedules="loadSchedulesWithGuard"
        @create-appointment="createAppointment"
        @search="searchDepartments"
        @open-doctor="openDoctorFromSearch"
      />

      <AuthView
        v-if="activePage === 'auth' && !user"
        :auth-mode="authMode"
        :account="account"
        :password="password"
        :register-type="registerType"
        :register-form="registerForm"
        @update:auth-mode="authMode = $event"
        @update:account="account = $event"
        @update:password="password = $event"
        @update:register-type="registerType = $event"
        @update:register-form="registerForm = $event"
        @login="login"
        @register="register"
        @back="activePage = 'booking'"
      />

      <PatientsView
        v-if="activePage === 'patients'"
        :user="user"
        :patients="patients"
        :new-patient="newPatient"
        @update:new-patient="newPatient = $event"
        @add-patient="addPatient"
      />

      <AppointmentsView
        v-if="activePage === 'appointments'"
        :appointments="appointments"
        @cancel-appointment="cancelAppointment"
      />

      <ProfileView
        v-if="activePage === 'profile'"
        :user="user"
        :profile-form="profileForm"
        :editing="profileEditing"
        @update:profile-form="profileForm = $event"
        @edit-profile="profileEditing = true"
        @update-profile="updateProfile"
      />

      <AppointmentSuccessView
        v-if="activePage === 'appointmentSuccess'"
        :appointment="latestAppointment"
        @view-appointments="activePage = 'appointments'"
        @book-again="activePage = 'booking'"
      />

      <AdminView
        v-if="activePage === 'admin'"
        :user="user"
        :stats="stats"
        :departments="adminDepartments"
        :doctors="doctors"
        :schedules="schedules"
        :selected-department="selectedDepartment"
        :selected-doctor="selectedDoctor"
        :schedule-edits="scheduleEdits"
        @load-doctors="loadDoctorsWithGuard"
        @load-schedules="loadSchedulesWithGuard"
        @change-schedule-edit="changeScheduleEdit"
        @update-schedule="updateSchedule"
      />

      <UserManagementView
        v-if="activePage === 'userManagement'"
        :user="user"
        :users="managedUsers"
        @refresh-users="loadManagedUsers"
        @toggle-user-status="toggleUserStatus"
      />
    </main>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { api } from './api'
import { navItems } from './constants'
import BookingView from './views/BookingView.vue'
import AuthView from './views/AuthView.vue'
import PatientsView from './views/PatientsView.vue'
import AppointmentsView from './views/AppointmentsView.vue'
import ProfileView from './views/ProfileView.vue'
import AppointmentSuccessView from './views/AppointmentSuccessView.vue'
import AdminView from './views/AdminView.vue'
import UserManagementView from './views/UserManagementView.vue'
import type {
  ActivePage,
  Appointment,
  Department,
  Doctor,
  NavItem,
  Patient,
  PatientForm,
  ProfileForm,
  RegisterForm,
  RegisterType,
  Schedule,
  ScheduleEdit,
  Statistics,
  User
} from './types'

interface ScheduleEditPayload {
  schedule: Schedule
  field: keyof ScheduleEdit
  value: number | ScheduleEdit['status']
}

function savedUser(): User | null {
  try {
    const saved = localStorage.getItem('hospital-user')
    return saved ? (JSON.parse(saved) as User) : null
  } catch {
    localStorage.removeItem('hospital-user')
    return null
  }
}

export default defineComponent({
  name: 'App',
  components: {
    BookingView,
    AuthView,
    PatientsView,
    AppointmentsView,
    ProfileView,
    AppointmentSuccessView,
    AdminView,
    UserManagementView
  },
  data() {
    const currentUser = savedUser()
    return {
      navItems,
      activePage: (window.location.hash === '#auth' ? 'auth' : 'booking') as ActivePage,
      user: currentUser,
      account: 'zhangsan',
      password: '123456',
      authMode: 'login',
      registerType: 'phone' as RegisterType,
      registerForm: { username: '', phone: '', email: '', password: '' } as RegisterForm,
      profileForm: {
        username: currentUser?.username || '',
        phone: currentUser?.phone || '',
        email: currentUser?.email || ''
      } as ProfileForm,
      profileEditing: false,
      message: '',
      keyword: '',
      departments: [] as Department[],
      adminDepartments: [] as Department[],
      doctors: [] as Doctor[],
      schedules: [] as Schedule[],
      searchDoctors: [] as Doctor[],
      patients: [] as Patient[],
      appointments: [] as Appointment[],
      managedUsers: [] as User[],
      selectedDepartment: null as Department | null,
      selectedDoctor: null as Doctor | null,
      selectedSchedule: null as Schedule | null,
      selectedPatientId: '' as number | string,
      latestAppointment: null as Appointment | null,
      newPatient: { name: '', idCard: '', phone: '', gender: 1, birthDate: '' } as PatientForm,
      scheduleEdits: {} as Record<number, ScheduleEdit>,
      stats: null as Statistics | null
    }
  },
  computed: {
    visibleNavItems(): NavItem[] {
      return this.navItems.filter((item) => {
        if (item.key === 'profile') return Boolean(this.user)
        if (item.key === 'admin' || item.key === 'userManagement') return this.user?.role === 'ADMIN'
        return true
      })
    },
    activeNav(): { label: string } | undefined {
      if (this.activePage === 'appointmentSuccess') {
        return { label: '预约成功' }
      }
      return this.navItems.find((item) => item.key === this.activePage)
    },
    todayText(): string {
      return new Intl.DateTimeFormat('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        weekday: 'short'
      }).format(new Date())
    }
  },
  mounted() {
    this.loadDepartments()
    this.loadAdminDepartments()
      if (this.user) {
      this.syncProfileForm()
      this.loadPatients(this.user.id)
      this.loadAppointments(this.user.id)
      if (this.user.role === 'ADMIN') this.loadStats()
    }
  },
  methods: {
    async run(action: () => Promise<void> | void) {
      try {
        this.message = ''
        await action()
      } catch (error) {
        this.message = error instanceof Error ? error.message : '操作失败'
      }
    },
    openAuth(mode: 'login' | 'register') {
      this.authMode = mode
      this.activePage = 'auth'
    },
    openPage(page: ActivePage) {
      if ((page === 'admin' || page === 'userManagement') && this.user?.role !== 'ADMIN') {
        this.message = '仅管理员可查看该模块'
        return
      }
      this.activePage = page
      if (page === 'profile') this.syncProfileForm()
      if (page === 'userManagement') this.loadManagedUsers()
      if (page === 'admin' && this.user?.role === 'ADMIN') {
        this.loadStats()
        this.loadAdminDepartments()
      }
    },
    syncProfileForm() {
      if (!this.user) return
      this.profileForm = {
        username: this.user.username,
        phone: this.user.phone || '',
        email: this.user.email || ''
      }
    },
    async loadDepartments(search = this.keyword) {
      const query = search ? `?keyword=${encodeURIComponent(search)}` : ''
      this.departments = await api.get<Department[]>(`/departments${query}`)
    },
    async loadAdminDepartments() {
      this.adminDepartments = await api.get<Department[]>('/departments')
    },
    updateKeyword(value: string) {
      this.keyword = value
      if (!value.trim()) {
        this.searchDoctors = []
        this.run(() => this.loadDepartments(''))
      }
    },
    async loadDoctors(department: Department) {
      this.selectedDepartment = department
      this.selectedDoctor = null
      this.selectedSchedule = null
      this.schedules = []
      this.doctors = await api.get<Doctor[]>(`/departments/${department.id}/doctors`)
    },
    loadDoctorsWithGuard(department: Department) {
      this.run(() => this.loadDoctors(department))
    },
    async loadSchedules(doctor: Doctor) {
      this.selectedDoctor = doctor
      this.selectedSchedule = null
      this.schedules = await api.get<Schedule[]>(`/doctors/${doctor.id}/schedules`)
    },
    loadSchedulesWithGuard(doctor: Doctor) {
      this.run(() => this.loadSchedules(doctor))
    },
    async loadPatients(userId: number) {
      const data = await api.get<Patient[]>(`/patients?userId=${userId}`)
      this.patients = data
      if (data.length && !this.selectedPatientId) this.selectedPatientId = data[0].id
    },
    async loadAppointments(userId: number) {
      this.appointments = await api.get<Appointment[]>(`/appointments?userId=${userId}`)
    },
    async loadStats() {
      this.stats = await api.get<Statistics>('/admin/statistics')
    },
    async loadManagedUsers() {
      if (this.user?.role !== 'ADMIN') return
      this.managedUsers = await api.get<User[]>(`/admin/users?adminId=${this.user.id}`)
    },
    login(event: Event) {
      event.preventDefault()
      this.run(async () => {
        const data = await api.post<User>('/auth/login', { account: this.account, password: this.password })
        this.user = data
        localStorage.setItem('hospital-user', JSON.stringify(data))
        this.syncProfileForm()
        this.activePage = 'booking'
        await this.loadPatients(data.id)
        await this.loadAppointments(data.id)
        if (data.role === 'ADMIN') await this.loadStats()
      })
    },
    register(event: Event) {
      event.preventDefault()
      this.run(async () => {
        const phone = this.registerForm.phone.trim()
        if (this.registerType === 'phone' && !/^1\d{10}$/.test(phone)) {
          throw new Error('请输入以1开头的11位手机号')
        }
        const payload = this.registerType === 'phone'
          ? { username: this.registerForm.username, phone, password: this.registerForm.password }
          : { username: this.registerForm.username, email: this.registerForm.email, password: this.registerForm.password }
        const data = await api.post<User>('/auth/register', payload)
        this.user = data
        localStorage.setItem('hospital-user', JSON.stringify(data))
        this.account = data.username
        this.password = this.registerForm.password
        this.syncProfileForm()
        this.registerForm = { username: '', phone: '', email: '', password: '' }
        this.authMode = 'login'
        this.activePage = 'booking'
        await this.loadPatients(data.id)
        await this.loadAppointments(data.id)
      })
    },
    logout() {
      localStorage.removeItem('hospital-user')
      this.user = null
      this.patients = []
      this.appointments = []
      this.managedUsers = []
      this.stats = null
      this.latestAppointment = null
      this.activePage = 'booking'
      this.profileEditing = false
    },
    updateProfile(event: Event) {
      event.preventDefault()
      this.run(async () => {
        if (!this.user) throw new Error('请先登录')
        const phone = this.profileForm.phone.trim()
        if (phone && !/^1\d{10}$/.test(phone)) {
          throw new Error('请输入以1开头的11位手机号')
        }
        if (!phone && !this.profileForm.email.trim()) {
          throw new Error('请至少保留手机号或邮箱')
        }
        const updated = await api.put<User>(`/users/${this.user.id}`, {
          username: this.profileForm.username.trim(),
          phone: phone || null,
          email: this.profileForm.email.trim() || null
        })
        this.user = updated
        localStorage.setItem('hospital-user', JSON.stringify(updated))
        this.syncProfileForm()
        this.profileEditing = false
        this.message = '个人信息已更新'
      })
    },
    addPatient(event: Event) {
      event.preventDefault()
      if (!this.user) return
      const idCard = this.newPatient.idCard.trim()
      const phone = this.newPatient.phone.trim()
      if (!/^\d{17}[\dXx]$/.test(idCard)) {
        this.message = '身份证号需为18位，最后一位可为数字或X'
        return
      }
      if (!/^1\d{10}$/.test(phone)) {
        this.message = '请输入以1开头的11位手机号'
        return
      }
      this.run(async () => {
        const created = await api.post<Patient>('/patients', { userId: this.user.id, ...this.newPatient, idCard, phone })
        this.newPatient = { name: '', idCard: '', phone: '', gender: 1, birthDate: '' }
        this.selectedPatientId = created.id
        await this.loadPatients(this.user.id)
        this.message = '就诊人已添加'
      })
    },
    createAppointment() {
      if (!this.user || !this.selectedSchedule || !this.selectedPatientId) {
        this.message = '请选择号源和就诊人'
        return
      }
      this.run(async () => {
        const data = await api.post<Appointment>('/appointments', {
          userId: this.user.id,
          patientId: this.selectedPatientId,
          scheduleId: this.selectedSchedule.id
        })
        await this.loadAppointments(this.user.id)
        if (this.selectedDoctor) await this.loadSchedules(this.selectedDoctor)
        this.latestAppointment = data
        this.selectedSchedule = null
        this.message = ''
        this.activePage = 'appointmentSuccess'
      })
    },
    cancelAppointment(id: number) {
      if (!this.user) return
      this.run(async () => {
        await api.post<Appointment>(`/appointments/${id}/cancel?userId=${this.user.id}`)
        await this.loadAppointments(this.user.id)
        if (this.selectedDoctor) await this.loadSchedules(this.selectedDoctor)
        this.message = '预约已取消'
      })
    },
    searchDepartments(event: Event) {
      event.preventDefault()
      this.activePage = 'booking'
      this.run(async () => {
        if (!this.keyword.trim()) {
          this.searchDoctors = []
          await this.loadDepartments('')
          return
        }
        const result = await api.get<{ departments?: Department[]; doctors?: Doctor[] }>(`/search?keyword=${encodeURIComponent(this.keyword)}`)
        this.departments = result.departments || []
        this.searchDoctors = result.doctors || []
      })
    },
    openDoctorFromSearch(doctor: Doctor) {
      this.run(async () => {
        const department = this.departments.find((item) => item.id === doctor.departmentId) || {
          id: doctor.departmentId,
          name: doctor.departmentName,
          description: ''
        }
        this.selectedDepartment = department
        this.selectedSchedule = null
        const departmentDoctors = await api.get<Doctor[]>(`/departments/${doctor.departmentId}/doctors`)
        this.doctors = departmentDoctors
        this.selectedDoctor = departmentDoctors.find((item) => item.id === doctor.id) || doctor
        this.schedules = await api.get<Schedule[]>(`/doctors/${doctor.id}/schedules`)
        this.searchDoctors = []
      })
    },
    changeScheduleEdit({ schedule, field, value }: ScheduleEditPayload) {
      this.scheduleEdits = {
        ...this.scheduleEdits,
        [schedule.id]: {
          ...(this.scheduleEdits[schedule.id] || {
            totalCount: schedule.totalCount,
            availableCount: schedule.availableCount,
            status: schedule.status
          }),
          [field]: value
        }
      }
    },
    updateSchedule(schedule: Schedule) {
      this.run(async () => {
        const edit = this.scheduleEdits[schedule.id] || schedule
        await api.put<void>(`/admin/schedules/${schedule.id}`, {
          totalCount: Number(edit.totalCount),
          availableCount: Number(edit.availableCount),
          status: edit.status
        })
        this.message = '排班已更新'
        if (this.selectedDoctor) await this.loadSchedules(this.selectedDoctor)
        if (this.user?.role === 'ADMIN') await this.loadStats()
      })
    },
    toggleUserStatus(managedUser: User) {
      this.run(async () => {
        if (this.user?.role !== 'ADMIN') throw new Error('仅管理员可操作')
        const nextStatus = managedUser.status === 0 ? 1 : 0
        await api.put<void>(`/admin/users/${managedUser.id}/status`, {
          adminId: this.user.id,
          status: nextStatus
        })
        await this.loadManagedUsers()
        this.message = nextStatus === 1 ? '用户已启用' : '用户已禁用'
      })
    }
  }
})
</script>
