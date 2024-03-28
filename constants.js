export const tinyMCEContentSettings = {
  menubar: false,
  inline: false,
  resize: false,
  statusbar: false,
  width: '100%',
  height: '300px',
  toolbar_drawer: 'floating',
  plugins: [
    'autolink',
    'lists'
  ],
  placeholder: 'Your message',
  toolbar: 'forecolor backcolor | alignleft aligncenter alignright | numlist bullist outdent indent | fontselect fontsizeselect',
  //content_css: '/v1/assets/css/tinymce_customcss.css',
  //content_style: '.tox.tox-tinymce{border: 1px solid #ced4da;}',
  force_br_newlines : true,
  force_p_newlines : false,
  forced_root_block : '',
}