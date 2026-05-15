export function DirectUploadLoading() {
  return (
    <div className="app">
      <div className="phone-shell" data-view="direct-upload-loading">
        <main className="app-main">
          <section className="connect-view" aria-label="正在加载配置">
            <div className="brand-lockup">
              <strong>KidMemory</strong>
              <small>Web Companion</small>
            </div>
            <p className="privacy-note" aria-live="polite">正在加载配置…</p>
          </section>
        </main>
      </div>
    </div>
  )
}