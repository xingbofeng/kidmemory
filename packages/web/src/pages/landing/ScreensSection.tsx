import React from 'react';

const ScreensSection: React.FC = () => {
  return (
    <section id="screens">
      <div className="head">
        <h2 data-i18n="screensTitle">桌面是工作台，Web Companion 是采集端。</h2>
        <p data-i18n="screensDesc">设计风格延续 KidMemory 的温暖、克制和童趣：柔和色块、清晰卡片、轻量插画感和真实产品界面共同服务家庭场景。</p>
      </div>
      <div className="showcase">
        <article className="show-main">
          <img src="design/images/desktop-asset-library.png" alt="KidMemory desktop asset library" />
          <div className="show-copy">
            <h3 data-i18n="assetTitle">Asset Library</h3>
            <p data-i18n="assetDesc">长期素材库是 KidMemory 的核心资产层。它保存的不只是图片，还有孩子、时间、语境、标签、描述、搜索向量和生成记录。</p>
          </div>
        </article>
        <div className="show-side">
          <article>
            <img src="design/images/desktop-generate-export.png" alt="KidMemory generate and export" />
            <div className="show-copy">
              <h3 data-i18n="generateTitle">Generate & Export</h3>
              <p data-i18n="generateDesc">从候选素材到结构化书稿，再到 HTML 预览、PDF 和长图输出。</p>
            </div>
          </article>
          <article>
            <img src="design/images/mobile-books-share.png" alt="KidMemory Web Companion books and share" />
            <div className="show-copy">
              <h3 data-i18n="mobileTitle">Web Companion</h3>
              <p data-i18n="mobileDesc">手机网页先承担扫码批量上传，后续扩展最近上传、作品集浏览、轻量搜索和亲友分享。</p>
            </div>
          </article>
        </div>
      </div>
    </section>
  );
};

export default ScreensSection;