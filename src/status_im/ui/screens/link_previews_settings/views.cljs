(ns status-im.ui.screens.link-previews-settings.views
  (:require-macros [status-im.utils.views :as views])
  (:require [re-frame.core :as re-frame]
            [status-im.i18n :as i18n]
  ;           [status-im.constants :as constants]
            [status-im.ui.components.react :as react]
            [status-im.ui.components.list.views :as list]
            [status-im.ui.components.colors :as colors]
  ;           [status-im.ui.screens.dapps-permissions.styles :as styles]
            [quo.core :as quo]
            [status-im.ui.components.icons.vector-icons :as icons]
            [status-im.ui.components.topbar :as topbar]
                      )
  )

(def urls-whitelist [{:title "YouTube" :url "https://youtube.com"}
                     {:title "Twitter" :url "https://twitter.com"}
                     {:title "GitHub"  :url "https://github.com"}])


(defn prepare-urls-items-data [{:keys [url title]}]
  {:title     title
   :subtitle  url
   :size      :small
   :accessory :switch
   :active true})


(views/defview link-previews-settings []
  (views/letsubs [permissions [:dapps/permissions]]
    [react/view {:flex 1}
     [topbar/topbar {:title (i18n/label :t/chat-link-previews)}]
     [icons/icon :main-icons/camera]
     [react/text (i18n/label :t/you-can-choose-preview-websites)]
     
     [quo/separator {:style {:margin-vertical  8}}]
     
     
     [quo/list-header (i18n/label :t/websites)]
     [quo/button {:on-press #()
                  :type     :secondary}
      (i18n/label :t/enable-all)]
     
     [list/flat-list
      {:data      (vec (map prepare-urls-items-data urls-whitelist))
       :key-fn    (fn [_ i] (str i))
       :render-fn quo/list-item
       :footer [react/i18n-text {:key :t/previewing-may-share-metadata
                                 :styles {:color colors/gray}}]}
      ]
     
     
     ]))
