import React from 'react';

const FinalSection: React.FC = () => {
  return (
    <section>
      <div className="final">
        <img src="design/images/design-system-overview.png" alt="KidMemory design system overview" />
        <div>
          <h2 data-i18n="finalTitle">私有、可迁移、可被家庭长期托付。</h2>
          <p data-i18n="finalDesc">KidMemory 把家庭素材库、语义搜图、Agent 书稿生成和作品导出整合在一个温暖的本地工作台里。孩子的作品被认真整理，父母的选择被保留，最终成品可以保存、打印，也可以放心分享给家人。</p>
          <a
            className="btn primary"
            href="/app"
            data-i18n="finalCta"
          >
            快速开始
          </a>
        </div>
      </div>
    </section>
  );
};

export default FinalSection;