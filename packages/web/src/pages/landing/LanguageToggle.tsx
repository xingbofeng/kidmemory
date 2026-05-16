import React, { useState, useEffect } from 'react';

interface LanguageToggleProps {}

const LanguageToggle: React.FC<LanguageToggleProps> = () => {
  const [currentLang, setCurrentLang] = useState<'zh' | 'en'>('zh');

  useEffect(() => {
    const savedLang = localStorage.getItem('kidmemory-lang') as 'zh' | 'en' || 'zh';
    setCurrentLang(savedLang);
    setLang(savedLang);
  }, []);

  const setLang = (lang: 'zh' | 'en') => {
    document.documentElement.lang = lang === "zh" ? "zh-CN" : "en";

    // Update all i18n elements
    document.querySelectorAll("[data-i18n]").forEach((node) => {
      const key = (node as HTMLElement).dataset.i18n;
      if (key && copy[lang][key as keyof typeof copy[typeof lang]]) {
        node.textContent = copy[lang][key as keyof typeof copy[typeof lang]];
      }
    });

    localStorage.setItem("kidmemory-lang", lang);
    setCurrentLang(lang);
  };

  const handleLanguageChange = (lang: 'zh' | 'en') => {
    setLang(lang);
  };

  return (
    <div className="lang" aria-label="Language switcher">
      <button
        className={currentLang === 'zh' ? 'active' : ''}
        onClick={() => handleLanguageChange('zh')}
      >
        中文
      </button>
      <button
        className={currentLang === 'en' ? 'active' : ''}
        onClick={() => handleLanguageChange('en')}
      >
        EN
      </button>
    </div>
  );
};

// Copy from original HTML - language content
const copy = {
  zh: {
    eyebrow: "Open source · local-first · memory publishing",
    slogan: "把孩子的照片、画作与成长瞬间，变成值得被珍藏的家庭记忆出版物。",
    desc: "KidMemory 是一个本地优先的 AI 家庭记忆出版系统。它不是相册，也不是模板堆叠工具，而是一条从素材采集、语义整理、Agent 生成到 PDF / 长图出版的完整工作流。",
    cta1: "阅读产品愿景",
    cta2: "快速开始",
    tag1: "本地优先",
    tag2: "Agent 驱动",
    tag3: "出版级输出",
    desktopTitle: "KidMemory Studio",
    noteTitle: "Memory, edited.",
    noteText: "从散落素材到结构化作品，让成长记录有主题、有章节、有成品。",
    visionTitle: "不是保存图片，而是重建家庭记忆的结构。",
    visionDesc: "KidMemory 的最终态是一套家庭记忆工作台：桌面端长期管理素材，Web Companion 负责手机扫码采集与轻量浏览，语义搜索重新发现，Agent 生成书稿，系统负责校验、预览、导出和归档。",
    visionCuratedTitle: "Curated, not piled up",
    visionCuratedDesc: "孩子的画作、照片、手工和早期表达不应该只堆在相册里。它们需要被重新挑选、排序、连接成故事。",
    visionAiEditorTitle: "AI as an editor",
    visionAiEditorDesc: "Agent 像编辑助理一样整理素材、生成结构、修复输出，但家庭的判断和叙事权始终留在用户手里。",
    visionPrivateTitle: "Private by design",
    visionPrivateDesc: "开源版从 macOS 桌面、本地文件、PostgreSQL + pgvector 和隔离 workspace 开始，把隐私和可迁移放在底层。",
    experienceTitle: "从素材到作品，是一条出版管线。",
    experienceDesc: "KidMemory 的体验不是\"上传后生成一下\"，而是从采集、整理、搜索、候选、生成、预览、导出到归档的连续工作流。",
    f1Title: "Capture",
    f1Desc: "手机扫码上传、相册选择、桌面拖拽，让纸面作品和生活瞬间进入素材库。",
    f2Title: "Curate",
    f2Desc: "为素材补充标题、标签、描述、时间、来源和孩子档案上下文。",
    f3Title: "Search",
    f3Desc: "用自然语言寻找素材，例如\"找画了太阳的作品\"或\"找适合做封面的图\"。",
    f4Title: "Publish",
    f4Desc: "Agent 生成结构化书稿，系统校验并导出 PDF、长图与未来更多作品形态。",
    screensTitle: "桌面是工作台，Web Companion 是采集端。",
    screensDesc: "设计风格延续 KidMemory 的温暖、克制和童趣：柔和色块、清晰卡片、轻量插画感和真实产品界面共同服务家庭场景。",
    assetTitle: "Asset Library",
    assetDesc: "长期素材库是 KidMemory 的核心资产层。它保存的不只是图片，还有孩子、时间、语境、标签、描述、搜索向量和生成记录。",
    generateTitle: "Generate & Export",
    generateDesc: "从候选素材到结构化书稿，再到 HTML 预览、PDF 和长图输出。",
    mobileTitle: "Web Companion",
    mobileDesc: "手机网页先承担扫码批量上传，后续扩展最近上传、作品集浏览、轻量搜索和亲友分享。",
    archTitle: "让 Agent 有创造力，也有边界。",
    archDesc: "系统先准备独立 workspace，Agent 只读输入、模板与规则，只写结构化输出。数据库、密钥、对象存储、导出和恢复都由系统掌控。",
    p1Title: "Workspace first",
    p1Desc: "每次生成先创建独立 job workspace，包含 input、templates、rules 和 output。",
    p2Title: "No secret access",
    p2Desc: "Agent 不直接访问数据库连接、API Key、对象存储凭据或本地敏感配置。",
    p3Title: "Schema-valid output",
    p3Desc: "`book.json` 必须可校验，`book.html` 必须可预览，生成结果可追踪。",
    p4Title: "System-owned export",
    p4Desc: "PDF、长图、备份恢复和失败重试由系统负责，保证作品稳定可打开。",
    mapDesktopTitle: "Desktop Studio",
    mapDesktopDesc: "素材整理、搜图、预览和导出入口。",
    mapSidecarTitle: "Node Sidecar",
    mapSidecarDesc: "连接配置、workspace、渲染与校验。",
    mapOutputTitle: "Memory Book",
    mapOutputDesc: "结构化书稿、HTML 预览、PDF 和长图。",
    mapDataTitle: "Private Library",
    mapDataDesc: "PostgreSQL + pgvector 与本地文件。",
    mapAgentTitle: "Agent Runner",
    mapAgentDesc: "只读输入和规则，写出可校验结果。",
    mapBadge: "local-first · safe workspace · publishable output",
    roadTitle: "一套完整的家庭记忆出版系统。",
    roadDesc: "KidMemory 把桌面工作台、私人素材库、语义搜索、Agent 生成、稳定导出和 Web Companion 采集合在同一条产品体验里，让家庭记忆从收集到出版自然流动。",
    r1Label: "Studio",
    r1Title: "桌面工作台",
    r1Desc: "macOS 桌面端承载孩子档案、素材整理、作品预览、生成任务和导出中心。",
    r2Label: "Library",
    r2Title: "私人素材库",
    r2Desc: "真实图片导入、metadata 编辑、标签管理、自然语言搜图、匹配原因和候选素材池。",
    r3Label: "Agent",
    r3Title: "可控生成系统",
    r3Desc: "Agent 在隔离 workspace 中生成结构化书稿，系统负责日志、校验、修复和稳定导出。",
    r4Label: "Upload",
    r4Title: "Web Companion 上传",
    r4Desc: "手机网页扫码进入 3 小时上传会话，单次最多 200 张，局域网优先，Supabase Storage 公网直传兜底。",
    r5Label: "Share",
    r5Title: "浏览与分享",
    r5Desc: "Web Companion 承接最近上传、轻量浏览、作品集查看、PDF / 长图分享和亲友传阅。",
    finalTitle: "私有、可迁移、可被家庭长期托付。",
    finalDesc: "KidMemory 把家庭素材库、语义搜图、Agent 书稿生成和作品导出整合在一个温暖的本地工作台里。孩子的作品被认真整理，父母的选择被保留，最终成品可以保存、打印，也可以放心分享给家人。",
    finalCta: "快速开始",
    footer: "A local-first AI publishing system for family memory."
  },
  en: {
    eyebrow: "Open source · local-first · memory publishing",
    slogan: "Turn children's photos, drawings, and growing moments into keepsake family publications.",
    desc: "KidMemory is a local-first AI publishing system for family memory. It is not an album app or a template stack, but a complete workflow from capture and semantic curation to Agent generation and PDF / long-image publishing.",
    cta1: "Read the vision",
    cta2: "Quick start",
    tag1: "Local-first",
    tag2: "Agent-powered",
    tag3: "Publication output",
    desktopTitle: "KidMemory Studio",
    noteTitle: "Memory, edited.",
    noteText: "Turn scattered materials into structured artifacts with themes, chapters, and finished publications.",
    visionTitle: "Not storing pictures. Rebuilding the structure of family memory.",
    visionDesc: "The ideal KidMemory is a family memory workspace: desktop for long-term asset management, Web Companion for phone-based capture and lightweight browsing, semantic search for rediscovery, Agents for book drafts, and the system for validation, preview, export, and archive.",
    visionCuratedTitle: "Curated, not piled up",
    visionCuratedDesc: "Children's artwork, photos, crafts, and early expressions should not just pile up in an album. They deserve selection, sequence, and story.",
    visionAiEditorTitle: "AI as an editor",
    visionAiEditorDesc: "Agents behave like editorial assistants: organizing material, generating structure, and repairing output while the family keeps judgment and narrative control.",
    visionPrivateTitle: "Private by design",
    visionPrivateDesc: "The open-source edition starts with macOS desktop, local files, PostgreSQL + pgvector, and isolated workspaces so privacy and portability sit at the foundation.",
    experienceTitle: "From material to artifact, it is a publishing pipeline.",
    experienceDesc: "KidMemory is not a single upload-and-generate moment. It is a continuous workflow from capture, curation, search, selection, generation, preview, export, and archive.",
    f1Title: "Capture",
    f1Desc: "QR upload, photo picker, and desktop drag-and-drop bring paper artwork and everyday moments into the library.",
    f2Title: "Curate",
    f2Desc: "Add titles, tags, descriptions, dates, sources, and child-profile context to each asset.",
    f3Title: "Search",
    f3Desc: "Find materials naturally, such as drawings with the sun or images suitable for a cover.",
    f4Title: "Publish",
    f4Desc: "Agents generate structured drafts, and the system validates and exports PDFs, long images, and future publication formats.",
    screensTitle: "Desktop is the studio. Web Companion is the capture surface.",
    screensDesc: "The visual language follows KidMemory's warm, restrained, and playful design system: soft color fields, clear cards, light illustration energy, and real product screens.",
    assetTitle: "Asset Library",
    assetDesc: "The long-lived asset library is KidMemory's core layer. It stores not only images, but child context, time, tags, descriptions, vectors, and generation records.",
    generateTitle: "Generate & Export",
    generateDesc: "Move from candidate assets to structured book drafts, HTML preview, PDF, and long-image output.",
    mobileTitle: "Web Companion",
    mobileDesc: "The phone web experience starts with QR batch upload, then expands into recent uploads, book browsing, lightweight search, and family sharing.",
    archTitle: "Give Agents creativity and boundaries.",
    archDesc: "The system prepares isolated workspaces first. Agents read inputs, templates, and rules, then write structured output. Database, secrets, storage, export, and recovery remain system-owned.",
    p1Title: "Workspace first",
    p1Desc: "Every generation starts with an isolated job workspace containing input, templates, rules, and output.",
    p2Title: "No secret access",
    p2Desc: "Agents do not directly access database connections, API keys, storage credentials, or sensitive local config.",
    p3Title: "Schema-valid output",
    p3Desc: "`book.json` must be valid, `book.html` must be previewable, and generation results stay traceable.",
    p4Title: "System-owned export",
    p4Desc: "PDF, long-image export, backup, recovery, and retry logic stay under system control.",
    mapDesktopTitle: "Desktop Studio",
    mapDesktopDesc: "The home for curation, search, preview, and export.",
    mapSidecarTitle: "Node Sidecar",
    mapSidecarDesc: "Configuration, workspaces, rendering, and validation.",
    mapOutputTitle: "Memory Book",
    mapOutputDesc: "Structured drafts, HTML preview, PDF, and long images.",
    mapDataTitle: "Private Library",
    mapDataDesc: "PostgreSQL + pgvector with local files.",
    mapAgentTitle: "Agent Runner",
    mapAgentDesc: "Reads inputs and rules, writes verifiable results.",
    mapBadge: "local-first · safe workspace · publishable output",
    roadTitle: "A complete family memory publishing system.",
    roadDesc: "KidMemory brings the desktop studio, private library, semantic search, Agent generation, reliable export, and Web Companion capture into one continuous product experience.",
    r1Label: "Studio",
    r1Title: "Desktop Studio",
    r1Desc: "The macOS desktop app hosts child profiles, asset curation, book previews, generation jobs, and the export center.",
    r2Label: "Library",
    r2Title: "Private Library",
    r2Desc: "Real image import, metadata editing, tag management, natural-language search, match reasons, and candidate pools.",
    r3Label: "Agent",
    r3Title: "Controlled Generation",
    r3Desc: "Agents generate structured books inside isolated workspaces while the system owns logs, validation, repair, and export.",
    r4Label: "Upload",
    r4Title: "Web Companion Upload",
    r4Desc: "The phone opens a 3-hour QR upload session, supports up to 200 images, prefers LAN upload, and falls back to Supabase Storage signed upload.",
    r5Label: "Share",
    r5Title: "Browse & Share",
    r5Desc: "Web Companion expands into recent uploads, lightweight browsing, book viewing, PDF / long-image sharing, and family circulation.",
    finalTitle: "Private, portable, and worthy of long-term family trust.",
    finalDesc: "KidMemory brings the family library, semantic search, Agent book generation, and artifact export into one warm local workspace. Children's work is curated with care, parents keep control, and the finished books are ready to save, print, and share.",
    finalCta: "Quick start",
    footer: "A local-first AI publishing system for family memory."
  }
} as const;

export default LanguageToggle;
