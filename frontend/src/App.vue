<template>
  <main class="container">
    <h1>Gestión de Usuarios</h1>
    <p v-if="loading">Cargando usuarios...</p>
    <p v-if="error" class="error">{{ error }}</p>
    <p v-if="message" class="success">{{ message }}</p>
    <form @submit.prevent="saveUser">
      <h2>{{ editingId ? 'Editar usuario' : 'Crear usuario' }}</h2>
      <input v-model.trim="form.name" placeholder="Nombre" required />
      <input v-model.trim="form.lastName" placeholder="Apellido" required />
      <input v-model.trim="form.email" type="email" placeholder="Correo" required />
      <input v-model.trim="form.gender" placeholder="Género" />
      <input v-model.trim="form.phone" placeholder="Teléfono" />
      <input v-model="form.birthDate" type="date" required />
      <button type="submit" :disabled="saving">
        {{ saving ? 'Guardando...' : editingId ? 'Actualizar' : 'Crear usuario' }}
      </button>
      <button v-if="editingId" type="button" @click="cancelEdit">
        Cancelar
      </button>
    </form>
    <p v-if="!loading && users.length === 0">
      No hay usuarios registrados.
    </p>
    <table v-if="users.length">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Apellido</th>
          <th>Email</th>
          <th>Teléfono</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.id">
          <td>{{ user.name }}</td>
          <td>{{ user.lastName }}</td>
          <td>{{ user.email }}</td>
          <td>{{ user.phone }}</td>
          <td>
            <button type="button" @click="editUser(user)">
              Editar
            </button>
            <button type="button" @click="deleteUser(user)">
              Eliminar
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </main>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'

const users = ref([])
const loading = ref(false)
const saving = ref(false)
const error = ref('')
const message = ref('')
const editingId = ref(null)

const emptyForm = () => ({
  name: '',
  lastName: '',
  email: '',
  gender: '',
  phone: '',
  birthDate: ''
})

const form = reactive(emptyForm())

async function loadUsers() {
  loading.value = true
  error.value = ''
  try {
    const response = await fetch('/api/users')
    if (!response.ok) {
      throw new Error(`Error al cargar usuarios: ${response.status}`)
    }
    users.value = await response.json()
  } catch (err) {
    error.value = err.message || 'No se pudieron cargar los usuarios.'
  } finally {
    loading.value = false
  }
}

function editUser(user) {
  editingId.value = user.id
  Object.assign(form, {
    name: user.name ?? '',
    lastName: user.lastName ?? '',
    email: user.email ?? '',
    gender: user.gender ?? '',
    phone: user.phone ?? '',
    birthDate: user.birthDate ?? ''
  })

  error.value = ''
  message.value = ''
}

async function saveUser() {
  saving.value = true
  error.value = ''
  message.value = ''

  const isEditing = editingId.value !== null
  const url = isEditing
    ? `/api/users/${editingId.value}`
    : '/api/users'
  try {
    const response = await fetch(url, {
      method: isEditing ? 'PUT' : 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ ...form })
    })
    if (!response.ok) {
      throw new Error(`Error al guardar usuario: ${response.status}`)
    }

    await response.json()

    message.value = isEditing
      ? 'Usuario actualizado correctamente.'
      : 'Usuario creado correctamente.'

    cancelEdit()
    await loadUsers()
  } catch (err) {
    error.value = err.message || 'No se pudo guardar el usuario.'
  } finally {
    saving.value = false
  }
}

async function deleteUser(user) {
  const confirmed = window.confirm(
    `¿Deseas eliminar a ${user.name} ${user.lastName}?`
  )
  if (!confirmed) return
  error.value = ''
  message.value = ''

  try {
    const response = await fetch(`/api/users/${user.id}`, {
      method: 'DELETE'
    })
    if (!response.ok) {
      throw new Error(`Error al eliminar usuario: ${response.status}`)
    }
    if (editingId.value === user.id) {
      cancelEdit()
    }
    message.value = 'Usuario eliminado correctamente.'
    await loadUsers()
  } catch (err) {
    error.value = err.message || 'No se pudo eliminar el usuario.'
  }
}

function cancelEdit() {
  editingId.value = null
  Object.assign(form, emptyForm())
}

async function registerHardcodedUserOnEntry() {
  const demoUser = {
    name: 'Usuario',
    lastName: 'Demostración',
    email: 'usuario.demo.symplifica@example.com',
    gender: 'No especificado',
    phone: '3000000000',
    birthDate: '1998-01-15'
  }

  loading.value = true
  error.value = ''
  message.value = ''

  try {
    const listResponse = await fetch('/api/users')
    if (!listResponse.ok) {
      throw new Error('No se pudieron consultar los usuarios.')
    }
    users.value = await listResponse.json()
    const alreadyExists = users.value.some(
      user =>
        user.email?.toLowerCase() ===
        demoUser.email.toLowerCase()
    )
    if (alreadyExists) {
      return
    }
    const createResponse = await fetch('/api/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(demoUser)
    })
    if (!createResponse.ok) {
      throw new Error(
        `No se pudo registrar el usuario: ${createResponse.status}`
      )
    }
    const refreshResponse = await fetch('/api/users')
    if (!refreshResponse.ok) {
      throw new Error('El usuario se creó, pero no se pudo actualizar la tabla.')
    }
    users.value = await refreshResponse.json()
    message.value = 'Usuario de prueba registrado automáticamente.'
  } catch (err) {
    error.value = err.message || 'Ocurrió un error inesperado.'
  } finally {
    loading.value = false
  }
}

onMounted(registerHardcodedUserOnEntry)

</script>

<style scoped>
.container {
  width: min(1100px, calc(100% - 40px));
  margin: 40px auto;
  padding: 32px;
  font-family:
    Inter, -apple-system, BlinkMacSystemFont,
    "Segoe UI", sans-serif;
  color: #1e293b;
  background: #ffffff;
  border: 1px solid #e8edf3;
  border-radius: 18px;
  box-shadow: 0 8px 30px rgb(15 23 42 / 5%);
}

h1 {
  margin: 0 0 8px;
  font-size: clamp(1.65rem, 3vw, 2.2rem);
  font-weight: 750;
  letter-spacing: -0.045em;
  color: #0f172a;
}

h1::after {
  content: "";
  display: block;
  width: 48px;
  height: 4px;
  margin-top: 14px;
  background: #2563eb;
  border-radius: 99px;
}

h2 {
  margin: 0 0 8px;
  color: #0f172a;
  font-size: 1.15rem;
  font-weight: 700;
}

form {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin: 28px 0 36px;
  padding: 24px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
}

form h2 {
  grid-column: 1 / -1;
  margin-bottom: 4px;
}

input {
  width: 100%;
  min-width: 0;
  box-sizing: border-box;
  padding: 12px 14px;
  color: #0f172a;
  font: inherit;
  font-size: 0.92rem;
  background: #ffffff;
  border: 1px solid #cbd5e1;
  border-radius: 9px;
  outline: none;
  transition:
    border-color 160ms ease,
    box-shadow 160ms ease;
}

input::placeholder {
  color: #94a3b8;
}

input:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgb(37 99 235 / 12%);
}

button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  min-height: 40px;
  margin: 0;
  padding: 10px 16px;
  font: inherit;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  border: 1px solid transparent;
  border-radius: 9px;
  transition:
    background-color 160ms ease,
    border-color 160ms ease,
    transform 160ms ease;
}

form button[type="submit"] {
  justify-self: start;
  color: #ffffff;
  background: #2563eb;
}

form button[type="submit"]:hover:not(:disabled) {
  background: #1d4ed8;
  transform: translateY(-1px);
}

form button[type="button"] {
  justify-self: start;
  color: #475569;
  background: #ffffff;
  border-color: #cbd5e1;
}

form button[type="button"]:hover {
  background: #f1f5f9;
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.error,
.success,
.container>p {
  font-size: 0.9rem;
  line-height: 1.5;
}

.error {
  padding: 12px 14px;
  color: #b91c1c;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 9px;
}

.success {
  padding: 12px 14px;
  color: #166534;
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
  border-radius: 9px;
}

table {
  width: 100%;
  margin-top: 16px;
  border-collapse: separate;
  border-spacing: 0;
  font-size: 0.9rem;
  overflow: hidden;
}

thead th {
  padding: 15px 16px;
  color: #475569;
  font-size: 0.75rem;
  font-weight: 700;
  text-align: left;
  text-transform: uppercase;
  letter-spacing: 0.045em;
  background: #f8fafc;
  border-top: 1px solid #e2e8f0;
  border-bottom: 1px solid #e2e8f0;
}

thead th:first-child {
  border-left: 1px solid #e2e8f0;
  border-top-left-radius: 10px;
}

thead th:last-child {
  border-right: 1px solid #e2e8f0;
  border-top-right-radius: 10px;
}

tbody td {
  padding: 15px 16px;
  color: #334155;
  border-bottom: 1px solid #e8edf3;
}

tbody tr {
  transition: background-color 150ms ease;
}

tbody tr:hover {
  background: #f8fafc;
}

tbody td:last-child {
  white-space: nowrap;
}

tbody td button:first-child {
  color: #1d4ed8;
  background: #eff6ff;
}

tbody td button:first-child:hover {
  background: #dbeafe;
}

tbody td button:last-child {
  margin-left: 6px;
  color: #b91c1c;
  background: #fef2f2;
}

tbody td button:last-child:hover {
  background: #fee2e2;
}

@media (max-width: 760px) {
  .container {
    width: calc(100% - 24px);
    margin: 16px auto;
    padding: 20px 16px;
    border-radius: 14px;
  }

  form {
    gap: 12px;
    padding: 16px;
  }

  table {
    display: block;
    overflow-x: auto;
    white-space: nowrap;
  }

  thead th,
  tbody td {
    padding: 12px;
  }
}

@media (max-width: 480px) {
  form {
    grid-template-columns: 1fr;
  }

  form h2 {
    grid-column: auto;
  }

  form button[type="submit"],
  form button[type="button"] {
    width: 100%;
  }
}

@media (prefers-reduced-motion: reduce) {

  *,
  *::before,
  *::after {
    transition-duration: 0.01ms !important;
    animation-duration: 0.01ms !important;
  }
}
</style>
