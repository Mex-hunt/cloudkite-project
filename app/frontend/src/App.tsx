import { FormEvent, useState } from "react";
import { LogOut, ShieldCheck } from "lucide-react";
import { AuthResponse, login, logout, register, runtimeConfig } from "./api";
import "./styles.css";

function binaryToken(value: string): string {
  return Array.from(value)
    .map((character) => character.charCodeAt(0).toString(2).padStart(8, "0"))
    .join(" ");
}

export function App() {
  const [view, setView] = useState<"login" | "register" | "hello">("login");
  const [registerEmail, setRegisterEmail] = useState("");
  const [registerName, setRegisterName] = useState("");
  const [registerPassword, setRegisterPassword] = useState("");
  const [loginEmail, setLoginEmail] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [token, setToken] = useState(() => window.localStorage.getItem("cloudkite:token") ?? "");
  const [user, setUser] = useState<AuthResponse["user"] | null>(null);
  const [registerMessage, setRegisterMessage] = useState("");
  const [loginMessage, setLoginMessage] = useState("");

  async function handleRegister(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setRegisterMessage("");

    try {
      await register(registerEmail, registerName, registerPassword);
      setLoginEmail(registerEmail);
      setLoginPassword("");
      setRegisterMessage("");
      setLoginMessage("Registration successful. Please login.");
      setView("login");
    } catch (error) {
      setRegisterMessage(error instanceof Error ? error.message : "Registration failed");
    }
  }

  async function handleLogin(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setLoginMessage("");

    try {
      const response = await login(loginEmail, loginPassword);
      window.localStorage.setItem("cloudkite:token", response.access_token);
      setToken(response.access_token);
      setUser(response.user);
      setView("hello");
    } catch (error) {
      setLoginMessage(error instanceof Error ? error.message : "Login failed");
    }
  }

  async function handleLogout() {
    if (token) {
      await logout(token).catch(() => undefined);
    }
    window.localStorage.removeItem("cloudkite:token");
    setToken("");
    setUser(null);
    setLoginMessage("Logged out");
    setView("login");
  }

  return (
    <main className="shell">
      <section className="hero">
        <div className="brand">
          <ShieldCheck size={30} />
          <div>
            <strong>CloudKite Auth</strong>
            <span>{runtimeConfig.environment} · v{runtimeConfig.appVersion}</span>
          </div>
        </div>
        <h1>Simple register and login</h1>
        <p>A user must register before login. After login, the app says hello with their email.</p>
      </section>

      <section className="single-view">
        {view === "login" ? (
        <form className="panel" onSubmit={handleLogin}>
          <h2>Login</h2>
          <label>
            Email
            <input type="email" value={loginEmail} onChange={(event) => setLoginEmail(event.target.value)} />
          </label>
          <label>
            Password
            <input type="password" value={loginPassword} onChange={(event) => setLoginPassword(event.target.value)} />
          </label>
          <button type="submit">Login</button>
          {loginMessage ? <p className="message">{loginMessage}</p> : null}
          <button type="button" className="link-button" onClick={() => {
            setLoginMessage("");
            setView("register");
          }}>
            Register instead
          </button>
        </form>
        ) : null}

        {view === "register" ? (
        <form className="panel" onSubmit={handleRegister}>
          <h2>Register</h2>
          <label>
            Name
            <input value={registerName} onChange={(event) => setRegisterName(event.target.value)} />
          </label>
          <label>
            Email
            <input type="email" value={registerEmail} onChange={(event) => setRegisterEmail(event.target.value)} />
          </label>
          <label>
            Password
            <input type="password" value={registerPassword} onChange={(event) => setRegisterPassword(event.target.value)} />
          </label>
          <button type="submit">Create account</button>
          {registerMessage ? <p className="message">{registerMessage}</p> : null}
          <button type="button" className="link-button" onClick={() => {
            setRegisterMessage("");
            setView("login");
          }}>
            Back to login
          </button>
        </form>
        ) : null}

        {view === "hello" && user ? (
        <section className="panel hello-panel">
          <h2>hello user = {user.email}</h2>
          <p>hello, here is your token</p>
          <div className="token-block" aria-label="Binary token">
            {binaryToken(token)}
          </div>
          <details>
            <summary>View raw token</summary>
            <div className="token-block raw-token">{token}</div>
          </details>
          <button type="button" className="secondary" onClick={handleLogout}>
            <LogOut size={17} />
            Logout
          </button>
        </section>
        ) : null}
      </section>
    </main>
  );
}
