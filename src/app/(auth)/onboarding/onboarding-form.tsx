'use client'

import { useActionState, useEffect, useState } from 'react'
import { createOrganization, type OnboardingState } from './actions'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

const initialState: OnboardingState = { status: 'idle' }

export function OnboardingForm() {
  const [state, formAction, pending] = useActionState(
    createOrganization,
    initialState,
  )

  // Clave de idempotencia estable por montaje del form (LR-002 lr_bug_008): un
  // retry del mismo submit (doble click / reintento tras respuesta perdida) reusa
  // esta clave → la RPC no crea una 2ª org. Se genera en efecto (post-mount) para no
  // romper la hidratación (el server no puede producir el mismo UUID random).
  const [requestId, setRequestId] = useState('')
  useEffect(() => {
    setRequestId(crypto.randomUUID())
  }, [])

  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle>Creá tu organización</CardTitle>
        <CardDescription>
          Es el espacio desde donde vas a publicar eventos y vender entradas.
          Vas a quedar como dueño.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form action={formAction} className="flex flex-col gap-4" noValidate>
          <input type="hidden" name="requestId" value={requestId} />
          <div className="flex flex-col gap-2">
            <Label htmlFor="name">Nombre de la organización</Label>
            <Input
              id="name"
              name="name"
              type="text"
              autoComplete="organization"
              placeholder="Productora La Puerta"
              required
              aria-invalid={state.status === 'error'}
              aria-describedby={
                state.status === 'error' ? 'name-error' : undefined
              }
            />
          </div>
          {state.status === 'error' && state.message ? (
            <p
              id="name-error"
              role="alert"
              className="text-sm text-destructive"
            >
              {state.message}
            </p>
          ) : null}
          <Button type="submit" disabled={pending || !requestId}>
            {pending ? 'Creando…' : 'Crear organización'}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}
