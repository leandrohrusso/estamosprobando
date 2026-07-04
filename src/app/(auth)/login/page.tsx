'use client'

import { useActionState } from 'react'
import { sendMagicLink, type LoginState } from './actions'
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

const initialState: LoginState = { status: 'idle' }

export default function LoginPage() {
  const [state, formAction, pending] = useActionState(
    sendMagicLink,
    initialState,
  )

  return (
    <main className="flex min-h-screen items-center justify-center bg-background p-4">
      <Card className="w-full max-w-sm">
        {state.status === 'sent' ? (
          <>
            <CardHeader>
              <CardTitle>Revisá tu email</CardTitle>
              <CardDescription>
                Te enviamos un enlace de acceso a{' '}
                <span className="font-medium text-foreground">{state.email}</span>
                . Abrilo desde este dispositivo para entrar.
              </CardDescription>
            </CardHeader>
          </>
        ) : (
          <>
            <CardHeader>
              <CardTitle>Entrar a PUERTITA</CardTitle>
              <CardDescription>
                Ingresá tu email y te enviamos un enlace de acceso. Sin
                contraseñas.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form action={formAction} className="flex flex-col gap-4" noValidate>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    name="email"
                    type="email"
                    autoComplete="email"
                    placeholder="vos@ejemplo.com"
                    required
                    aria-invalid={state.status === 'error'}
                    aria-describedby={
                      state.status === 'error' ? 'email-error' : undefined
                    }
                  />
                </div>
                {state.status === 'error' && state.message ? (
                  <p
                    id="email-error"
                    role="alert"
                    className="text-sm text-destructive"
                  >
                    {state.message}
                  </p>
                ) : null}
                <Button type="submit" disabled={pending}>
                  {pending ? 'Enviando…' : 'Enviarme el enlace'}
                </Button>
              </form>
            </CardContent>
          </>
        )}
      </Card>
    </main>
  )
}
