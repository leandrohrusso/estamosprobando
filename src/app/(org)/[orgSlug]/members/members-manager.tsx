'use client'

import { useActionState, useEffect, useRef } from 'react'
import { addMember, changeRole, removeMember, type AddMemberState } from './actions'
import type { OrgMember } from '@/lib/auth/org'
import type { AssignableRole } from '@/lib/auth/schemas'
import { roleLabel } from '@/lib/auth/roles'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

const initialState: AddMemberState = { status: 'idle' }

const ASSIGNABLE_ROLES: AssignableRole[] = ['admin', 'staff']

export function MembersManager({
  orgSlug,
  members,
}: {
  orgSlug: string
  members: OrgMember[]
}) {
  const [state, formAction, pending] = useActionState(addMember, initialState)
  const formRef = useRef<HTMLFormElement>(null)

  // Limpia el form tras un alta exitosa (el nuevo miembro aparece en la lista
  // por el revalidate del server action). En error se conservan los valores.
  useEffect(() => {
    if (state.status === 'added') formRef.current?.reset()
  }, [state])

  return (
    <div className="flex flex-col gap-8">
      {/* Alta de miembro */}
      <form
        ref={formRef}
        action={formAction}
        className="flex flex-col gap-3 rounded-lg border border-border bg-card p-4"
        noValidate
      >
        <input type="hidden" name="orgSlug" value={orgSlug} />
        <div className="flex flex-col gap-2 sm:flex-row sm:items-end">
          <div className="flex flex-1 flex-col gap-2">
            <Label htmlFor="member-email">Email del miembro</Label>
            <Input
              id="member-email"
              name="email"
              type="email"
              autoComplete="off"
              placeholder="persona@ejemplo.com"
              required
              aria-invalid={state.status === 'error'}
              aria-describedby={
                state.status === 'error' ? 'member-error' : undefined
              }
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="member-role">Rol</Label>
            <select
              id="member-role"
              name="role"
              defaultValue="staff"
              className="h-10 rounded-md border border-input bg-background px-3 text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ring-offset-background"
            >
              {ASSIGNABLE_ROLES.map((r) => (
                <option key={r} value={r}>
                  {roleLabel(r)}
                </option>
              ))}
            </select>
          </div>
          <Button type="submit" disabled={pending}>
            {pending ? 'Agregando…' : 'Agregar'}
          </Button>
        </div>
        {state.status === 'error' && state.message ? (
          <p id="member-error" role="alert" className="text-sm text-destructive">
            {state.message}
          </p>
        ) : null}
        {state.status === 'added' && state.email ? (
          <p role="status" className="text-sm text-success">
            Invitaste a {state.email}. Va a poder entrar con ese email.
          </p>
        ) : null}
      </form>

      {/* Lista de miembros */}
      <ul className="flex flex-col divide-y divide-border rounded-lg border border-border">
        {members.map((member) => (
          <li
            key={`${member.id}:${member.role}:${member.status}`}
            className="flex flex-wrap items-center gap-3 p-4"
          >
            <div className="flex flex-1 flex-col">
              <span className="font-medium text-card-foreground">
                {member.email}
                {member.isSelf ? (
                  <span className="text-small text-fg-4"> · vos</span>
                ) : null}
              </span>
              <span className="text-small text-fg-4">
                {member.status === 'pending' ? 'Pendiente' : 'Activo'}
              </span>
            </div>

            {member.role === 'owner' ? (
              <span className="text-sm text-muted-foreground">
                {roleLabel(member.role)}
              </span>
            ) : (
              <div className="flex items-center gap-2">
                <form action={changeRole}>
                  <input type="hidden" name="orgSlug" value={orgSlug} />
                  <input type="hidden" name="membershipId" value={member.id} />
                  <select
                    name="role"
                    defaultValue={member.role}
                    aria-label={`Rol de ${member.email}`}
                    onChange={(e) => e.currentTarget.form?.requestSubmit()}
                    className="h-9 rounded-md border border-input bg-background px-2 text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ring-offset-background"
                  >
                    {ASSIGNABLE_ROLES.map((r) => (
                      <option key={r} value={r}>
                        {roleLabel(r)}
                      </option>
                    ))}
                  </select>
                </form>
                <form action={removeMember}>
                  <input type="hidden" name="orgSlug" value={orgSlug} />
                  <input type="hidden" name="membershipId" value={member.id} />
                  <Button
                    type="submit"
                    variant="ghost"
                    size="sm"
                    aria-label={`Quitar a ${member.email}`}
                  >
                    Quitar
                  </Button>
                </form>
              </div>
            )}
          </li>
        ))}
      </ul>
    </div>
  )
}
