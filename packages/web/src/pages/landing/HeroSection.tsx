import React from 'react';

const HeroSection: React.FC = () => {
  return (
    <section className="hero">
      <div>
        <div className="eyebrow" data-i18n="eyebrow">Open source · local-first · memory publishing</div>
        <h1>KidMemory</h1>
        <p className="slogan" data-i18n="slogan">把孩子的照片、画作与成长瞬间，变成值得被珍藏的家庭记忆出版物。</p>
        <p className="desc" data-i18n="desc">KidMemory 是一个本地优先的 AI 家庭记忆出版系统。它不是相册，也不是模板堆叠工具，而是一条从素材采集、语义整理、Agent 生成到 PDF / 长图出版的完整工作流。</p>
        <div className="cta">
          <a className="btn primary" href="#vision" data-i18n="cta1">阅读产品愿景</a>
          <a className="btn secondary" href="/app" data-i18n="cta2">快速开始</a>
        </div>
        <div className="tags">
          <span className="tag" data-i18n="tag1">本地优先</span>
          <span className="tag" data-i18n="tag2">Agent 驱动</span>
          <span className="tag" data-i18n="tag3">出版级输出</span>
        </div>
      </div>

      <div className="visual" aria-label="KidMemory product preview">
        <div className="desktop">
          <div className="top">
            <div className="dots"><span className="dot"></span><span className="dot"></span><span className="dot"></span></div>
            <strong data-i18n="desktopTitle">KidMemory Studio</strong>
            <span></span>
          </div>
          <div className="product-shot">
            <img src="design/images/page-overview.png" alt="KidMemory product overview" />
          </div>
        </div>
        <div className="phone">
          <div className="screen">
            <img src="design/images/mobile-upload.png" alt="KidMemory mobile upload" />
          </div>
        </div>
        <div className="note-card">
          <b data-i18n="noteTitle">Memory, edited.</b>
          <span data-i18n="noteText">从散落素材到结构化作品，让成长记录有主题、有章节、有成品。</span>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;