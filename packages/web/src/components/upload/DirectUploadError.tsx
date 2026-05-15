interface DirectUploadErrorProps {
  title: string
  message: string
  description?: string
}

export function DirectUploadError({ title, message, description }: DirectUploadErrorProps) {
  return (
    <div className="app">
      <div className="phone-shell" data-view="direct-upload-error">
        <main className="app-main">
          <section className="connect-view" aria-labelledby="direct-upload-error-title">
            <div className="brand-lockup">
              <strong>KidMemory</strong>
              <small>Web Companion</small>
            </div>
            <h1 id="direct-upload-error-title">{title}</h1>
            <div className="inline-alert danger" role="alert">
              {message}
            </div>
            {description && (
              <p className="privacy-note">{description}</p>
            )}
          </section>
        </main>
      </div>
    </div>
  )
}