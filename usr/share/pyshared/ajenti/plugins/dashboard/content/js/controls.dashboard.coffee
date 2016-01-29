class window.Controls.dashboard__dash extends window.Control
    createDom: () ->
        """
            <div class="control container dashboard-dash">
                <div class="container widget-container container-0" data-index="0">
                </div>
                <div class="container widget-container container-1" data-index="1">
                </div>
                <div class="widget-storage"><children></div>
                <div class="container trash">
                    <i class="icon-trash"></i>
                </div>
            </div>
        """

    setupDom: (dom) ->
        super(dom)
        jQuery(@dom).children('.container').sortable({
            connectWith: '.dashboard-dash .container'
            handle: '.handle'
            revert: 200
            placeholder: 'placeholder'
            tolerance: 'pointer'
            start: () =>
                @event('drag_start', {})
            stop: () =>
                @event('drag_stop', {})
                r = {}
                $(@dom).children('.widget-container').each (i, c) =>
                    index = parseInt($(c).attr('data-index'))
                    r[index] = []
                    $(c).children().each (i, e) =>
                        r[index].push(parseInt($(e).attr('data-uid')))
                @event('reorder', indexes: r)
        })

        $(@dom).find('.widget-storage > *').each (i, e) =>
            $(@dom).find(".container-#{$(e).attr('data-container')}").append(e)


class window.Controls.dashboard__widget extends window.Control
    createDom: () ->
        """
            <div data-uid="#{@properties.uid}" data-container="#{@properties.container}" class="control dashboard-widget">
                <div class="handle"></div>
                <div class="content __child-container"><children></div>
                <a class="configure"><i class="icon-wrench"></i></a>
                <a class="delete"><i class="icon-remove"></i></a>
            </div>
        """

    setupDom: (dom) ->
        super(dom)
        if not @properties.configurable
            $(@dom).children('a.configure').remove()
        $(@dom).children('a.configure').click () =>
            @event('configure', {})
        $(@dom).children('a.delete').click () =>
            @event('delete', {})


class window.Controls.dashboard__header extends window.Control
    createDom: () ->
        """
            <div class="control dashboard-header">
                <div class="labels" style="padding-left:20px">
                    <div class="hostname">#{@s(@properties.hostname)}</div>
                    <div class="distro">DIG Engineering Kiosk 0.1</div>
                </div>

                <div class="inner"><children></div>
            </div>
        """


class window.Controls.dashboard__welcome extends window.Control
    createDom: () ->
        """
            <div class="control container welcome">
                Welcome to Ajenti.<br/>
                Use the <b>Feedback</b> link to send us your suggestions!<br/>

                <br/>
                Follow @ajenti for news and announcements.</br>
                
                <iframe allowtransparency="true" frameborder="0" scrolling="no" src="//platform.twitter.com/widgets/follow_button.html?screen_name=ajenti&show_count=true&dnt=true" style="width:300px; height:20px;"></iframe>
                <br/>
                <br/>

                <a href="mailto:e@ajenti.org">Send e-mail</a> if you have private/security questions or issues.<br/>
                <br/>
                <b>Don't forget to change default password in the Configurator!</b>
            </div>
        """
