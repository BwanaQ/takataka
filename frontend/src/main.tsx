import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./styles.css";

function App() {
  return (
    <main className="shell">
      <section className="hero">
        <p className="eyebrow">KITUI COUNTY · COUNTY 15</p>
        <h1>Taka Taka</h1>
        <h2>Turning Waste Into Worth</h2>
        <p className="intro">
          AI-powered circular economy intelligence for Kenya.
        </p>
        <div className="status-card">
          <span className="dot" />
          Sprint 1 foundation is running.
        </div>
      </section>
    </main>
  );
}

createRoot(document.getElementById("root")!).render(
  <StrictMode><App /></StrictMode>
);
