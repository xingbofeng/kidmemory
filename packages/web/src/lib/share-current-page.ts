interface ShareNavigator {
  share?: (data: { title: string; text: string; url: string }) => Promise<void>
  clipboard: Pick<Clipboard, 'writeText'>
}

interface ShareCurrentPageOptions {
  title: string
  text: string
  url: string
  copiedMessage: string
  navigatorRef?: ShareNavigator
  alertRef?: (message: string) => void
}

export function shareCurrentPage({
  title,
  text,
  url,
  copiedMessage,
  navigatorRef = navigator,
  alertRef = alert,
}: ShareCurrentPageOptions): void {
  if (navigatorRef.share) {
    void navigatorRef.share({ title, text, url })
    return
  }

  void navigatorRef.clipboard.writeText(url)
  alertRef(copiedMessage)
}
