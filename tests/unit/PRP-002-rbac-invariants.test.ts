import { describe, it, expect } from 'vitest'
import {
  assignableRoleSchema,
  addMemberSchema,
  changeRoleSchema,
  createOrganizationSchema,
} from '../../src/lib/auth/schemas'
import { sortMembersPendingFirst, type OrgMember } from '../../src/lib/auth/org'

// LR-002 · invariante Owner-inmutable a nivel app (anti-lockout · SD-cos-11). El
// Owner NO es un rol asignable desde la gestión de miembros: alta y cambio de rol
// solo aceptan admin|staff · así ninguna acción de UI puede crear un 2º Owner ni
// promover a Owner. La red RLS equivalente vive en tests/sql (mbr_write).
describe('assignableRoleSchema · Owner no es asignable', () => {
  it('acepta admin y staff', () => {
    expect(assignableRoleSchema.safeParse('admin').success).toBe(true)
    expect(assignableRoleSchema.safeParse('staff').success).toBe(true)
  })

  it('rechaza owner y valores desconocidos', () => {
    expect(assignableRoleSchema.safeParse('owner').success).toBe(false)
    expect(assignableRoleSchema.safeParse('root').success).toBe(false)
  })
})

describe('addMemberSchema / changeRoleSchema · rechazan role=owner', () => {
  const membershipId = '00000000-0000-0000-0000-0000000000aa'

  it('addMember no puede dar de alta un Owner', () => {
    expect(
      addMemberSchema.safeParse({ email: 'x@y.com', role: 'owner' }).success,
    ).toBe(false)
    expect(
      addMemberSchema.safeParse({ email: 'x@y.com', role: 'staff' }).success,
    ).toBe(true)
  })

  it('changeRole no puede promover a Owner', () => {
    expect(
      changeRoleSchema.safeParse({ membershipId, role: 'owner' }).success,
    ).toBe(false)
    expect(
      changeRoleSchema.safeParse({ membershipId, role: 'admin' }).success,
    ).toBe(true)
  })
})

// LR-002 lr_bug_008 · createOrganization exige la clave de idempotencia (UUID).
describe('createOrganizationSchema · requestId obligatorio', () => {
  it('rechaza sin requestId o con requestId no-UUID', () => {
    expect(createOrganizationSchema.safeParse({ name: 'Mi Org' }).success).toBe(
      false,
    )
    expect(
      createOrganizationSchema.safeParse({ name: 'Mi Org', requestId: 'nope' })
        .success,
    ).toBe(false)
  })

  it('acepta name válido + requestId UUID', () => {
    expect(
      createOrganizationSchema.safeParse({
        name: 'Mi Org',
        requestId: '11111111-2222-4333-8444-555555555555',
      }).success,
    ).toBe(true)
  })
})

// LR-002 · orden pending-first (invitaciones piden acción · el sort va en JS y no
// por la columna enum `status`, cuyo orden de declaración es un acoplamiento frágil).
describe('sortMembersPendingFirst', () => {
  const member = (
    email: string,
    status: 'pending' | 'active',
  ): OrgMember => ({
    id: email,
    email,
    role: 'staff',
    status,
    isSelf: false,
  })

  it('pone los pendientes primero preservando el orden previo por grupo', () => {
    const input = [
      member('a-active@x.com', 'active'),
      member('b-pending@x.com', 'pending'),
      member('c-active@x.com', 'active'),
      member('d-pending@x.com', 'pending'),
    ]
    const out = sortMembersPendingFirst(input)
    expect(out.map((m) => m.email)).toEqual([
      'b-pending@x.com',
      'd-pending@x.com',
      'a-active@x.com',
      'c-active@x.com',
    ])
  })

  it('no muta el input', () => {
    const input = [member('a@x.com', 'active'), member('b@x.com', 'pending')]
    const snapshot = input.map((m) => m.email)
    sortMembersPendingFirst(input)
    expect(input.map((m) => m.email)).toEqual(snapshot)
  })
})
