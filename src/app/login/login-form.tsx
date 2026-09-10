'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { LogIn, User, Lock, Loader2, AlertTriangle, HelpCircle, ChevronDown, ChevronUp } from 'lucide-react'
import { useRouter } from 'next/navigation'

interface ErrorDetails {
    message: string
    detail?: string
    suggestion?: string
    category?: 'DATABASE' | 'CREDENTIALS' | 'SERVER'
    errorCode?: string
}

export default function LoginForm() {
    const [view, setView] = useState<'login' | 'forgot'>('login')
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [isLoading, setIsLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const [errorDetails, setErrorDetails] = useState<ErrorDetails | null>(null)
    const [showTechnicalDetails, setShowTechnicalDetails] = useState(true)
    const [successMsg, setSuccessMsg] = useState<string | null>(null)
    const router = useRouter()

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault()
        setIsLoading(true)
        setError(null)
        setErrorDetails(null)
        setSuccessMsg(null)

        try {
            const res = await fetch('/api/auth/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email, password }),
            })

            let data: any = {}
            const rawText = await res.text()
            try {
                data = JSON.parse(rawText)
            } catch (e) {
                data = {
                    message: `Error en respuesta del servidor (HTTP ${res.status})`,
                    detail: rawText || 'El servidor devolvió una respuesta no válida (HTML o texto).',
                    category: 'SERVER',
                    suggestion: '1. Verifique que el servicio backend Korex_NextJS esté activo.\n2. Revise que las credenciales de SQL Server en .env sean correctas.'
                }
            }

            if (!res.ok) {
                const details: ErrorDetails = {
                    message: data.message || 'Error en el inicio de sesión',
                    detail: data.detail,
                    suggestion: data.suggestion,
                    category: data.category,
                    errorCode: data.errorCode
                }
                setErrorDetails(details)
                setShowTechnicalDetails(true)
                throw new Error(data.message || 'Error en el inicio de sesión')
            }

            // Save user to localStorage
            localStorage.setItem('user', JSON.stringify(data.user))

            router.push('/dashboard')
        } catch (err: any) {
            setError(err.message)
        } finally {
            setIsLoading(false)
        }
    }

    const handleForgotPassword = async (e: React.FormEvent) => {
        e.preventDefault()
        setIsLoading(true)
        setError(null)
        setErrorDetails(null)
        setSuccessMsg(null)

        try {
            const res = await fetch('/api/auth/forgot-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email }),
            })

            const data = await res.json()

            if (!res.ok) {
                const details: ErrorDetails = {
                    message: data.message || 'Error al procesar solicitud',
                    detail: data.detail,
                    suggestion: data.suggestion
                }
                setErrorDetails(details)
                throw new Error(data.message + (data.detail ? ` (detalle: ${data.detail})` : ''))
            }

            setSuccessMsg(data.message)
        } catch (err: any) {
            setError(err.message)
        } finally {
            setIsLoading(false)
        }
    }

    if (view === 'forgot') {
        return (
            <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                className="w-full max-w-md bg-white dark:bg-zinc-900/50 backdrop-blur-xl p-8 rounded-2xl shadow-2xl border border-zinc-200 dark:border-zinc-800"
            >
                <div className="flex flex-col items-center mb-8">
                    <div className="w-16 h-16 bg-purple-600 rounded-2xl flex items-center justify-center mb-4 shadow-lg shadow-purple-500/30">
                        <Lock className="text-white w-8 h-8" />
                    </div>
                    <h1 className="text-3xl font-bold text-zinc-900 dark:text-white text-center">Recuperar Contraseña</h1>
                    <p className="text-zinc-500 dark:text-zinc-400 mt-2 text-center">Ingresa tu email para recibir instrucciones</p>
                </div>

                <form onSubmit={handleForgotPassword} className="space-y-6">
                    <div>
                        <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-2">Email</label>
                        <div className="relative">
                            <User className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 w-5 h-5" />
                            <input
                                type="email"
                                required
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                className="w-full pl-10 pr-4 py-3 bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-purple-500 outline-none transition-all"
                                placeholder="ejemplo@correo.com"
                            />
                        </div>
                    </div>

                    {errorDetails ? (
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            className="bg-red-500/10 border border-red-500/20 dark:border-red-500/30 rounded-xl p-4 text-left space-y-2"
                        >
                            <div className="flex items-start gap-2.5">
                                <AlertTriangle className="w-5 h-5 text-red-500 shrink-0 mt-0.5" />
                                <div className="flex-1">
                                    <h4 className="text-sm font-bold text-red-600 dark:text-red-400">{errorDetails.message}</h4>
                                    {errorDetails.suggestion && (
                                        <p className="text-xs text-zinc-600 dark:text-zinc-300 mt-1 whitespace-pre-line leading-relaxed font-mono">
                                            {errorDetails.suggestion}
                                        </p>
                                    )}
                                </div>
                            </div>
                        </motion.div>
                    ) : error && (
                        <div className="text-red-500 text-sm text-center bg-red-500/10 py-2 px-4 rounded-lg">
                            {error}
                        </div>
                    )}

                    {successMsg && (
                        <div className="text-emerald-500 text-sm text-center bg-emerald-500/10 py-3 px-4 rounded-xl font-medium">
                            {successMsg}
                        </div>
                    )}

                    <button
                        type="submit"
                        disabled={isLoading}
                        className="w-full h-12 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-xl transition-all flex items-center justify-center shadow-lg shadow-purple-500/30 disabled:opacity-70"
                    >
                        {isLoading ? <Loader2 className="animate-spin" /> : 'Enviar Enlace'}
                    </button>

                    <button
                        type="button"
                        onClick={() => {
                            setView('login')
                            setError(null)
                            setErrorDetails(null)
                            setSuccessMsg(null)
                        }}
                        className="w-full text-zinc-500 dark:text-zinc-400 text-sm font-medium hover:text-zinc-900 dark:hover:text-white transition-colors"
                    >
                        Volver al inicio de sesión
                    </button>
                </form>
            </motion.div>
        )
    }

    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="w-full max-w-md bg-white dark:bg-zinc-900/50 backdrop-blur-xl p-8 rounded-2xl shadow-2xl border border-zinc-200 dark:border-zinc-800"
        >
            <div className="flex flex-col items-center mb-8">
                <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center mb-4 shadow-lg shadow-blue-500/30">
                    <LogIn className="text-white w-8 h-8" />
                </div>
                <h1 className="text-3xl font-bold text-zinc-900 dark:text-white">Bienvenido</h1>
                <p className="text-zinc-500 dark:text-zinc-400 mt-2">Accede a tu panel de agencias</p>
            </div>

            <form onSubmit={handleLogin} className="space-y-6">
                <div>
                    <label className="block text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-2">Email</label>
                    <div className="relative">
                        <User className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 w-5 h-5" />
                        <input
                            type="email"
                            required
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full pl-10 pr-4 py-3 bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            placeholder="ejemplo@correo.com"
                        />
                    </div>
                </div>

                <div>
                    <div className="flex justify-between items-center mb-2">
                        <label className="text-sm font-medium text-zinc-700 dark:text-zinc-300">Contraseña</label>
                        <button
                            type="button"
                            onClick={() => setView('forgot')}
                            className="text-xs font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400"
                        >
                            ¿Olvidaste tu contraseña?
                        </button>
                    </div>
                    <div className="relative">
                        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 w-5 h-5" />
                        <input
                            type="password"
                            required
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full pl-10 pr-4 py-3 bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                            placeholder="••••••••"
                        />
                    </div>
                </div>

                {errorDetails ? (
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="bg-red-500/10 border border-red-500/20 dark:border-red-500/30 rounded-xl p-4 text-left space-y-3"
                    >
                        <div className="flex items-start gap-3">
                            <div className="p-2 bg-red-500/20 text-red-500 rounded-lg shrink-0 mt-0.5">
                                <AlertTriangle className="w-5 h-5" />
                            </div>
                            <div className="flex-1 min-w-0">
                                <div className="flex items-center justify-between gap-2">
                                    <h4 className="text-sm font-bold text-red-600 dark:text-red-400 leading-tight">
                                        {errorDetails.message}
                                    </h4>
                                    {errorDetails.category && (
                                        <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 bg-red-500/20 text-red-400 rounded-full shrink-0">
                                            {errorDetails.category === 'DATABASE' ? 'BD/SQL' : errorDetails.category}
                                        </span>
                                    )}
                                </div>

                                {errorDetails.suggestion && (
                                    <div className="mt-2 text-xs text-zinc-600 dark:text-zinc-300 bg-white/50 dark:bg-zinc-800/60 p-2.5 rounded-lg border border-zinc-200 dark:border-zinc-700/50 space-y-1">
                                        <div className="font-semibold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 text-[11px] text-amber-600 dark:text-amber-400">
                                            <HelpCircle className="w-3.5 h-3.5" />
                                            Pasos sugeridos para solucionar:
                                        </div>
                                        <div className="whitespace-pre-line text-[11px] leading-relaxed opacity-90 font-mono">
                                            {errorDetails.suggestion}
                                        </div>
                                    </div>
                                )}

                                {errorDetails.detail && (
                                    <div className="mt-2">
                                        <button
                                            type="button"
                                            onClick={() => setShowTechnicalDetails(!showTechnicalDetails)}
                                            className="text-[11px] text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200 flex items-center gap-1 font-medium transition-colors"
                                        >
                                            {showTechnicalDetails ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />}
                                            {showTechnicalDetails ? 'Ocultar detalle técnico' : 'Ver detalle técnico del error'}
                                        </button>

                                        {showTechnicalDetails && (
                                            <motion.pre
                                                initial={{ opacity: 0, height: 0 }}
                                                animate={{ opacity: 1, height: 'auto' }}
                                                className="mt-1.5 p-2.5 bg-zinc-950 text-red-300 text-[10px] font-mono rounded-lg overflow-x-auto border border-red-900/40 break-all whitespace-pre-wrap max-h-36"
                                            >
                                                {errorDetails.detail}
                                                {errorDetails.errorCode ? `\n[Código Error: ${errorDetails.errorCode}]` : ''}
                                            </motion.pre>
                                        )}
                                    </div>
                                )}
                            </div>
                        </div>
                    </motion.div>
                ) : error && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="text-red-500 text-sm text-center bg-red-500/10 py-2 rounded-lg"
                    >
                        {error}
                    </motion.div>
                )}

                <button
                    type="submit"
                    disabled={isLoading}
                    className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition-all flex items-center justify-center shadow-lg shadow-blue-500/30 disabled:opacity-70"
                >
                    {isLoading ? <Loader2 className="animate-spin" /> : 'Iniciar Sesión'}
                </button>
            </form>
        </motion.div>
    )
}
