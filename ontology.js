function scrollAndHighlightElement(n) {
    OBrowserNavigation.getInstance().theDetailsMgr.scrollAndHighlightElement(n)
}

function goAndScrollAndHighlightElement(n, t) {
    OBrowserNavigation.getInstance().goAndScrollAndHighlightElement(n, t)
}
var __extends = this && this.__extends || function() {
        var n = Object.setPrototypeOf || {
            __proto__: []
        }
        instanceof Array && function(n, t) {
            n.__proto__ = t
        } || function(n, t) {
            for (var i in t) t.hasOwnProperty(i) && (n[i] = t[i])
        };
        return function(t, i) {
            function r() {
                this.constructor = t
            }
            n(t, i);
            t.prototype = i === null ? Object.create(i) : (r.prototype = i.prototype, new r)
        }
    }(),
    ApplicationStateInformation = function() {
        function n() {}
        return n
    }(),
    OntologyBasicInfo = function() {
        function n() {
            this.rootClickURLEnding = ""
        }
        return n.prototype.getFoundationBasicInfo = function() {
            if (!this.isLinearization && this.ontologyKey == "f") return this;
            if (this._foundationBasicInfo !== undefined) return this._foundationBasicInfo;
            var t = new n;
            return t.ontologyKey = "f", t.theLanguage = this.theLanguage, t.isLinearization = !1, t.baseURL = this.baseURL, t.ontologyLabel = "ICD-11 Foundation", t.ontologyId = "ICD-11Beta", t._foundationBasicInfo = null, this._foundationBasicInfo = t, this._foundationBasicInfo
        }, n.prototype.getRootURL = function() {
            return this.baseURL + this.ontologyKey.toLowerCase() + "/" + this.theLanguage
        }, n.prototype.getLinearizationId = function() {
            return this.isLinearization ? this.ontologyId.substr(this.getFoundationBasicInfo().ontologyId.length, this.ontologyId.length - this.getFoundationBasicInfo().ontologyId.length) : undefined
        }, n.prototype.rightLoadURL = function(n, t) {
            return this.getDetailsURL(n, t)
        }, n.prototype.getDetailsURL = function(n, t) {
            var i = this.getRootURL() + "/GetConcept?ConceptId=" + n;
            return t != undefined && t != null ? i + "&data=" + encodeURIComponent(JSON.stringify(t)) : i
        }, n.prototype.getRootConceptsURL = function() {
            return this.getRootURL() + "/JsonGetRootConcepts?useHtml=false"
        }, n.prototype.getChildrenConceptsURL = function(n) {
            return this.getRootURL() + "/JsonGetChildrenConcepts?ConceptId=" + n + "&useHtml=false"
        }, n.prototype.getParentConceptsURL = function(n) {
            return this.getRootURL() + "/JsonGetParentConcepts?ConceptId=" + n + "&useHtml=false"
        }, n.prototype.getConceptURL = function(n) {
            return this.getRootURL() + "/JsonGetConcept?ConceptId=" + n + "&useHtml=false"
        }, n.prototype.getRootConceptsURLForTreeRendering = function() {
            return this.getRootURL() + "/JsonGetRootConcepts?useHtml=true"
        }, n.prototype.getChildrenConceptsURLForTreeRendering = function(n, t) {
            return this.getRootURL() + "/JsonGetChildrenConcepts?ConceptId=" + n + "&useHtml=true&showAdoptedChildren=" + t
        }, n.prototype.getParentConceptIDsToRootURL = function(n) {
            return this.getRootURL() + "/JsonGetParentConceptIDsToRoot?ConceptId=" + n
        }, n.convertToFoundationId = function(n) {
            var t, i;
            return n.indexOf("entity") > 0 ? n : (t = n.split("/"), t.length < 8 || t.length > 9) ? n : (i = t[0] + "//" + t[2] + "/" + t[3] + "/entity/" + t[7], t.length == 9 && (i = i + "/" + t[6] + "/" + t[8]), i)
        }, n
    }(),
    OntologyInfoForTranslation = function(n) {
        function t() {
            return n !== null && n.apply(this, arguments) || this
        }
        return __extends(t, n), t.prototype.getRootURL = function() {
            return this.baseURL + "translate/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage + "/" + this.sourceLanguage + "/" + this.translationLanguage
        }, t.prototype.rightLoadURL = function(n) {
            return this.getTranslationPageURL(n)
        }, t.prototype.getTranslationPageURL = function(n) {
            return this.baseURL + "translateentity/" + this.ontologyKey.toLowerCase() + "/" + this.sourceLanguage + "/" + this.translationLanguage + "?conceptID=" + n
        }, t.prototype.getRootConceptsURLForTreeRendering = function() {
            return this.baseURL + "translate/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage + "/" + this.translationLanguage + "/JsonGetRootConcepts"
        }, t.prototype.getChildrenConceptsURLForTreeRendering = function(n) {
            return this.baseURL + "translate/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage + "/" + this.translationLanguage + "/JsonGetChildrenConcepts?ConceptId=" + n
        }, t.prototype.relatedTranslationsURL = function(n) {
            return this.baseURL + "relatedtranslations/" + this.ontologyKey + "/en/" + this.translationLanguage + "?text=" + n
        }, t.prototype.getParentConceptIDsToRootURL = function(n) {
            return this.baseURL + this.ontologyKey.toLowerCase() + "/" + this.theLanguage + "/JsonGetParentConceptIDsToRoot?ConceptId=" + n
        }, t
    }(OntologyBasicInfo),
    OntologyInfoForManualCodeAssigner = function(n) {
        function t() {
            return n !== null && n.apply(this, arguments) || this
        }
        return __extends(t, n), t.prototype.rightLoadURL = function(n) {
            return "#anc" + n.replace("http://id.who.int/", "").replace(/\//g, "x")
        }, t
    }(OntologyBasicInfo),
    OntologyInfoForProposals = function(n) {
        function t() {
            return n !== null && n.apply(this, arguments) || this
        }
        return __extends(t, n), t.prototype.getRootURL = function() {
            return this.baseURL + "proposals/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage
        }, t.prototype.getRootConceptsURLForTreeRendering = function() {
            return this.getRootURL() + "/JsonGetRootConcepts"
        }, t.prototype.getChildrenConceptsURLForTreeRendering = function(n) {
            return this.getRootURL() + "/JsonGetChildrenConcepts?ConceptId=" + n
        }, t.prototype.getDetailsUrlForProposals = function(n) {
            var t = $.address.parameter("action"),
                r = $.address.parameter("stableProposalGroupId"),
                u = $.address.parameter("readOnly"),
                o = $.address.parameter("reviewMode"),
                f = $.address.parameter("contentreviewNo"),
                e = $.address.parameter("c"),
                i = $.address.parameter("includeDescendants");
            return i == undefined && (i = "false"), t != undefined ? r != undefined ? this.baseURL + "proposals/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage + "/" + t + "?conceptID=" + n + "&stableProposalGroupId=" + r + "&readOnly=" + u : this.baseURL + "proposals/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage + "/" + t + "?conceptID=" + n + "&readOnly=" + u + "&contentreviewNo=" + f + "&c=" + e : this.baseURL + "proposals/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage + "/EntityProposals?conceptID=" + n + "&includeDescendants=" + i
        }, t.prototype.getvaluesetSearchUrl = function(n, t) {
            return this.baseURL + "valueset/" + n + "/search?q=" + t
        }, t.prototype.getProposalPostUrl = function(n, t) {
            return this.getRootURL() + "/" + n + "?conceptID=" + t
        }, t.prototype.rightLoadURL = function(n) {
            return this.getDetailsUrlForProposals(n)
        }, t.prototype.getStatusChangeUrl = function() {
            return this.baseURL + "proposals/jsonchangestatus"
        }, t
    }(OntologyBasicInfo),
    OntologyInfoForReviews = function(n) {
        function t() {
            return n !== null && n.apply(this, arguments) || this
        }
        return __extends(t, n), t.prototype.getRootURL = function() {
            return this.baseURL + "reviews/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage
        }, t.prototype.getProposalRootUrl = function() {
            return this.baseURL + "proposals/" + this.ontologyKey.toLowerCase() + "/" + this.theLanguage
        }, t.prototype.getRootConceptsURLForTreeRendering = function() {
            return this.getProposalRootUrl() + "/JsonGetRootConcepts"
        }, t.prototype.getChildrenConceptsURLForTreeRendering = function(n) {
            return this.getProposalRootUrl() + "/JsonGetChildrenConcepts?ConceptId=" + n
        }, t.prototype.getDetailsUrlForReviews = function(n) {
            return this.getRootURL() + "/EntityReviews?ConceptId=" + n
        }, t.prototype.rightLoadURL = function(n) {
            return this.getDetailsUrlForReviews(n)
        }, t
    }(OntologyBasicInfo),
    ExistingContentReviewPage = function() {
        function n() {}
        return n.prototype.reloadContent = function() {
            var n = location.href.replace("ExistingContentReviewProposalStandAlone", "ExistingContentReviewProposal");
            $("#existingcrpartial").load(n)
        }, n
    }(),
    OBrowserContributions = function() {
        function n() {
            if (n._instance) throw new Error("Error: Instantiation failed: Use OBrowserContributions.getInstance() instead of new.");
        }
        return n.getInstance = function() {
            return n._instance === null && (n._instance = new n), n._instance
        }, n.prototype.initialize = function(n, t) {
            this.baseURL = n;
            this._hostObject = t
        }, n.prototype.toggleCommentArea = function(n) {
            $("#commentarea_" + n).toggle();
            $("#commentbox_" + n).hide();
            $("#addbutton_" + n).show()
        }, n.prototype.toggleCommentAreaWithAdd = function(n) {
            $("#commentarea_" + n).toggle();
            $("#commentbox_" + n).show();
            $("#addbutton_" + n).hide()
        }, n.prototype.showAddNewComment = function(n) {
            $("#commentbox_" + n).show();
            $("#addbutton_" + n).hide()
        }, n.prototype.showAddThreadedComment = function(n, t) {
            $("#threadcommentbox_" + n).toggle();
            $("#addbutton_" + t).hide()
        }, n.prototype.addComment = function(n, t, i) {
            var f = this,
                r, u;
            $("#commentwait_" + t).show();
            $(n).removeAttr("onClick");
            $(n).off("click");
            r = this.baseURL + "Contributions/AddComment";
            u = $("#ctb_" + t).val();
            $.post(r, {
                contributableId: i,
                commentText: u
            }, function(n) {
                f._hostObject.reloadContent(function() {
                    $("#commentarea_" + t).show()
                });
                $("#messageArea").html(n.message).dialog("open")
            })
        }, n.prototype.addCommentToThread = function(n, t, i, r, u) {
            var o = this,
                f, e;
            $("#commentwait").show();
            $(n).removeAttr("onClick");
            $(n).off("click");
            f = this.baseURL + "Contributions/AddCommentToThread";
            e = $("#ctb_" + i).val();
            $.post(f, {
                contributableId: r,
                commentText: e,
                threadId: u
            }, function(n) {
                o._hostObject.reloadContent(function() {
                    $("#commentarea_" + t).show("slow")
                });
                $("#messageArea").html(n.message).dialog("open")
            })
        }, n.prototype.toggleQArea = function(n, t) {
            var i = this;
            if ($("#saqdialog_" + n).attr("dialog") == undefined) {
                var r = $("#saqimg_" + n).offset().left + $("#saqimg_" + n).width(),
                    u = $("#saqimg_" + n).offset().top + $("#saqimg_" + n).height(),
                    f = $("#firstright").height();
                $("#saqdialog_" + n).dialog({
                    autoOpen: !0,
                    close: function() {
                        i.destructSAQDialog(n)
                    },
                    show: "fade",
                    hide: "fade",
                    title: "Question",
                    buttons: {
                        Submit: function() {
                            i.submitSAQ(n, t)
                        },
                        Cancel: function() {
                            i.destructSAQDialog(n)
                        }
                    },
                    position: [r, u],
                    width: 480
                }).css("max-height", f);
                $("#saqdialog_" + n).attr("dialog", "true");
                $.validator.unobtrusive.parse("#saqform_" + n);
                $("#saqform_" + n).validate()
            } else this.destructSAQDialog(n)
        }, n.prototype.destructSAQDialog = function(n) {
            this.destroyDialog("#saqdialog_" + n);
            typeof(this._hostObject.openQuestion == "function") && this._hostObject.openQuestion(null)
        }, n.prototype.destroyDialog = function(n) {
            $(n).dialog("destroy");
            $(n).removeAttr("dialog")
        }, n.prototype.submitSAQ = function(n, t) {
            var u = this,
                i = {},
                r;
            $.each($("#saqform_" + n).serializeArray(), function(n, t) {
                i[t.name] = t.value
            });
            i.entityId = t;
            n.substr(0, 3) == "SPQ" ? (r = this.baseURL + "/SPQ/SPQAnswer", i.SPQId = n) : r = this.baseURL + "/Contributions/SAQAnswer";
            $("#saqform_" + n).valid() == !0 && $.post(r, i, function(t) {
                $("#messageArea").html(t).dialog("open");
                u.destructSAQDialog(n)
            })
        }, n.prototype.retireContribution = function(n, t) {
            var u = this,
                i = {},
                r;
            i.contributionId = n;
            r = this.baseURL + "/Contributions/RetireContribution";
            $.post(r, i, function(n) {
                u._hostObject.reloadContent(function() {
                    $("#commentarea_" + t + " .firstcomment").length > 0 && $("#commentarea_" + t).show("slow")
                });
                $("#messageArea").html(n).dialog("open")
            })
        }, n.prototype.opinion = function(n, t, i) {
            var u = this,
                r;
            t == -9999 ? r = $("<div>Are you sure to report this entry as SPAM<\/div>").dialog({
                autoOpen: !0,
                show: "fade",
                hide: "fade",
                buttons: {
                    OK: function() {
                        u.postOpinion(n, t, i);
                        r.dialog("close")
                    },
                    Cancel: function() {
                        $(this).dialog("close")
                    }
                }
            }) : this.postOpinion(n, t, i)
        }, n.prototype.removeOpinion = function(n, t) {
            var u = this,
                i = {},
                r;
            i.contributionId = n;
            r = this.baseURL + "/Contributions/RemoveUserOpinion";
            $.post(r, i, function(n) {
                var i = $.address.path().substr(1, $.address.path().length - 1);
                u._hostObject.reloadContent(function() {
                    $("#commentarea_" + t + " .firstcomment").length > 0 && $("#commentarea_" + t).show("slow")
                });
                $("#messageArea").html(n).dialog("open")
            })
        }, n.prototype.postOpinion = function(n, t, i) {
            var f = this,
                r = {},
                u;
            r.contributionId = n;
            r.opinion = t;
            u = this.baseURL + "/Contributions/AddUserOpinion";
            $.post(u, r, function(n) {
                var t = $.address.path().substr(1, $.address.path().length - 1);
                f._hostObject.reloadContent(function() {
                    $("#commentarea_" + i + " .firstcomment").length > 0 && $("#commentarea_" + i).show("slow")
                });
                $("#messageArea").html(n).dialog("open")
            })
        }, n.prototype.inviteForContribution = function(n) {
            var t = this.baseURL + "contributions/invitationmail?url=" + n;
            $.get(t, function(n) {
                window.location.href = "mailto:?subject=" + n.subject + "&body=" + n.body
            })
        }, n.prototype.userOpinions = function(n) {
            var t = this.baseURL + "contributions/GetAllOpinions?contributionId=" + n;
            $.get(t, function(n) {
                $(n).dialog({
                    autoOpen: !0,
                    show: "fade",
                    hide: "fade",
                    buttons: {
                        Close: function() {
                            $(this).dialog("close")
                        }
                    }
                })
            })
        }, n.prototype.removeSpamStatus = function(n) {
            var t = {},
                i;
            t.contributionId = n;
            i = this.baseURL + "/Contributions/RemoveSpamStatus";
            $.post(i, t, function(n) {
                $("<div><\/div>").html(n).dialog({
                    autoOpen: !0,
                    show: "fade",
                    hide: "fade",
                    buttons: {
                        OK: function() {
                            window.location.reload()
                        }
                    }
                })
            })
        }, n.prototype.retireContribution2 = function(n, t) {
            var i = {},
                r;
            i.contributionId = n;
            r = this.baseURL + "/Contributions/RetireContribution";
            t == !0 && (i.unretire = !0);
            $.post(r, i, function(n) {
                $("<div><\/div>").html(n).dialog({
                    autoOpen: !0,
                    show: "fade",
                    hide: "fade",
                    buttons: {
                        OK: function() {
                            window.location.reload()
                        }
                    }
                })
            })
        }, n._instance = null, n
    }(),
    DataLoadOptions = function() {
        function n() {
            this.loadChildren = !0;
            this.loadParents = !0;
            this.includeAllAncestors = !1;
            this.loadAllAncestorsOfChildren = !1;
            this.includeLinearizationInformation = !1
        }
        return n
    }(),
    BrowserDataLoader = function() {
        function n(n, t) {
            this._octEntities = new OCTEntities;
            this._oInfo = n;
            t == undefined ? (this._root = {}, this._root.ID = "http://id.who.int/icd/entity", this._root.label = "ICD", this._root.averageDepth = -1, this._root.isLeaf = !1, this._root.isAdoptedChild = !1) : this._root = t;
            this.memoizedGetParentData = _.memoize(this.getParentData, function(n) {
                return n.ID
            })
        }
        return n.prototype.getData = function(n, t) {
            $.ajax({
                type: "GET",
                url: n,
                dataType: "json",
                headers: {
                    Accept: "application/json"
                }
            }).done(function(n) {
                t(n)
            })
        }, n.prototype.loadData = function(n, t, i, r, u) {
            var f = this,
                e = {
                    count: 0
                },
                o = this._oInfo.getConceptURL(t);
            n.includeLinearizationInformation && (o = o + "&includeDetailedLinearizationInfo=true");
            e.count++;
            this.getData(o, function(u) {
                var h = new OCTEntity(u),
                    o, s;
                h != null && (o = f._octEntities.addEntity(h), h == o && i(o, 1), n.loadChildren && (s = f._oInfo.getChildrenConceptsURL(t), n.includeLinearizationInformation && (s = s + "&includeDetailedLinearizationInfo=true"), e.count++, f.getData(s, function(t) {
                    for (var s, h, u = 0; u < t.length; ++u) s = new OCTEntity(t[u]), t[u] = f._octEntities.addEntity(s), h = o.addChild(t[u]), t[u].addParent(o), s == t[u] && i(t[u], t.length), h && r("parent", t[u], o), u > 0 && r("prevSibling", t[u], t[u - 1]), n.loadAllAncestorsOfChildren && f.memoizedGetParentData(t[u], n, e, function(n, t) {
                        var o = new OCTEntity(n),
                            u = new OCTEntity(t),
                            e = f._octEntities.addEntity(o),
                            s;
                        u = f._octEntities.addEntity(u);
                        s = e.addChild(u);
                        u.addParent(e);
                        o == e && i(e, 1);
                        s && r("parent", u, e)
                    });
                    e.count--
                })), n.loadParents && f.memoizedGetParentData(o, n, e, function(n, t) {
                    var o = new OCTEntity(n),
                        u = new OCTEntity(t),
                        e = f._octEntities.addEntity(o),
                        u = f._octEntities.addEntity(u),
                        s = e.addChild(u);
                    u.addParent(e);
                    o == e && i(e, 1);
                    s && r("parent", u, e)
                }), e.count--)
            });
            this.waitLoop(e, function() {
                u()
            })
        }, n.prototype.getParentData = function(n, t, i, r) {
            var f = this,
                u = this._oInfo.getParentConceptsURL(n.ID);
            t.includeLinearizationInformation && (u = u + "&includeDetailedLinearizationInfo=true");
            i.count++;
            this.getData(u, function(u) {
                var e, o;
                if (u.length == 0) r(f._root, n), i.count--;
                else if (t.includeAllAncestors) {
                    for (e = 0; e < u.length; ++e) o = u[e], r(o, n), f.memoizedGetParentData(o, t, i, r);
                    i.count--
                } else u.forEach(function(t) {
                    r(t, n);
                    i.count--
                })
            })
        }, n.prototype.waitLoop = function(n, t) {
            var i = this;
            this.loadTimeout = setTimeout(function() {
                n.count <= 0 ? t() : i.waitLoop(n, t)
            }, 300)
        }, n
    }(),
    OBrowserDetails = function() {
        function n() {}
        return n.prototype.scrollAndHighlightElement = function(n) {
            var i = n.replace(".", "\\."),
                t = $("#" + i);
            if (t.length == 0) {
                if (i.length == 1) return;
                n = n.substring(0, n.length - 1);
                n.substr(n.length - 1, 1) == "." && (n = n.substring(0, n.length - 1));
                i = n.replace(".", "\\.");
                t = $("#" + i)
            }
            t.length > 0 && ($("#firstright").scrollTo(t, 400, {
                offset: {
                    top: -55,
                    left: 0
                }
            }), t.parent().addClass("highlight"))
        }, n.prototype.showancestors = function() {
            $(".allancestors").show();
            $(".onlyparent").hide()
        }, n.prototype.hideancestors = function() {
            $(".allancestors").hide();
            $(".onlyparent").show()
        }, n.prototype.showindexentries = function() {
            $(".indexvisible").show();
            $(".indexhidden").hide()
        }, n.prototype.hideindexentries = function() {
            $(".indexvisible").hide();
            $(".indexhidden").show()
        }, n
    }(),
    OBrowserHierarchy = function() {
        function n() {
            this.pseudoLinearizationMode = !1
        }
        return n.prototype.initialize = function() {
            var n = this,
                t, i;
            this.tree = new YAHOO.widget.TreeView(this.treeLocationDivId);
            this.tree.setDynamicLoad(function(t, i) {
                n.loadNodeData(t, i)
            });
            this.tree.subscribe("expandComplete", function() {
                n.expandCompleteCallback()
            });
            this.tree.subscribe("expand", function(t) {
                t.isLeaf === !1 && t.children.length === 1 && t.dynamicLoadComplete === !0 && t.childrenRendered === !0 && n.tree.removeChildren(t)
            });
            this.tree.singleNodeHighlight = !0;
            this.tree.subscribe("clickEvent", this.tree.onEventToggleHighlight);
            t = this.tree.getRoot();
            i = {
                ID: this.oInfo.ontologyKey,
                html: "<a class='ygtvlabel' data-id='root'>" + this.rootLabel + "<\/a>",
                isLeaf: !1,
                isAdoptedChild: !1,
                label: this.rootLabel
            };
            this.errorNode = {
                html: "<a class='ygtvlabel error' data-id='error'>**** ERROR occured in Loading Content! Please try again by closing and re-opening the parent node or refresing the page<\/a>",
                isLeaf: !0,
                isAdoptedChild: !1,
                label: "ERROR occured in Loading Content"
            };
            this.ontroot = new YAHOO.widget.HTMLNode(i, t, !1);
            this.ontroot.expand();
            this.tree.draw();
            $("#" + this.treeLocationDivId).off().on("click", "", function(t) {
                var r = t.target.getAttribute("data-id"),
                    i;
                r != null ? n.itemClickedCallback(r) : (i = $(t.target).parent().attr("data-id"), i != null && n.itemClickedCallback(i))
            })
        }, n.prototype.treeSync = function(n) {
            if (this.tree == undefined && this.initialize(), n != undefined) {
                var t = this.tree.getNodeByProperty("ID", n);
                t != null ? (t.highlight(!0), t.focus()) : this.highlightUnloadedNode(n)
            }
        }, n.prototype.loadNodeData = function(n, t) {
            var r = this,
                i, u;
            n != null && (n.data.ID == this.oInfo.ontologyKey ? (i = this.oInfo.getRootConceptsURLForTreeRendering(), this.isLinearizationInclusionIconVisible() && (i = Helper.updateQueryStringParameter(i, "showLinearizationInclusionIcon", "true"))) : (i = this.oInfo.getChildrenConceptsURLForTreeRendering(n.data.ID, this.showAdoptedChildren()), (this.oInfo.isLinearization == !0 || this.pseudoLinearizationMode == !0) && (i = i + "&isAdoptedChild=" + n.data.isAdoptedChild), this.isLinearizationInclusionIconVisible() && (i = i + "&showLinearizationInclusionIcon=true"), this.pseudoLinearizationMode && (i = i + "&pseudoLinearizationMode=true")), u = {
                success: function(oResponse) {
                    for (var oResults = eval("(" + oResponse.responseText + ")"), treeNode, tempNode, i = 0; i < oResults.length; i++) treeNode = r.tree.getNodeByProperty("ID", oResults[i].ID), (treeNode == null || treeNode.parent.data.ID != n.data.ID) && (tempNode = new YAHOO.widget.HTMLNode(oResults[i], n, oResults[i].isLeaf, !0), tempNode.multiExpand = !0);
                    oResponse.argument.fnLoadComplete()
                },
                failure: function(t) {
                    YAHOO.log("Failed to process transaction.", "info", "example");
                    r.errorNode = new YAHOO.widget.HTMLNode(r.errorNode, n, !1);
                    t.argument.fnLoadComplete()
                },
                argument: {
                    node: n,
                    fnLoadComplete: t
                },
                timeout: 2e4
            }, YAHOO.util.Connect.asyncRequest("GET", i, u))
        }, n.prototype.highlightUnloadedNode = function(n) {
            var t = this;
            n != "DummyID" && $.get(this.oInfo.getParentConceptIDsToRootURL(n), function(i) {
                try {
                    if (i == null) return
                } catch (r) {
                    $.address.path("");
                    return
                }
                if (i != undefined) {
                    if (i[0] != n) {
                        alert("Error!!! " + i);
                        return
                    }
                    i[i.length] = t.oInfo.ontologyKey;
                    t.doIt(n, i, -1)
                }
            })
        }, n.prototype.doIt = function(n, t, i) {
            var u = this,
                r, e, f;
            if (i < 0) {
                for (r = 0; r < t.length; ++r)
                    if (this.tree.getNodeByProperty("ID", t[r]) != null) break;
                i = r
            }
            e = t[i];
            f = this.tree.getNodeByProperty("ID", e);
            this.loadNodeData(f, function() {
                var r, e;
                f.expand();
                r = u.tree.getNodeByProperty("ID", n);
                r == null ? (i = i - 1, u.doIt(n, t, i)) : (r.highlight(!0), e = 'a[data-id="' + n + '"]', u.waitAndScroll(e, 5, 400))
            })
        }, n.prototype.waitAndScroll = function(n, t, i) {
            var r = this;
            t != 0 && setTimeout(function() {
                var u = $("div.outer-west " + n),
                    f;
                if (u.length > 0) {
                    f = $("div.outer-west");
                    f.height() < u.position().top && $("div.outer-west").scrollTo(u, 800);
                    return
                }
                r.waitAndScroll(n, t - 1, i)
            }, i)
        }, n.prototype.collapseTree = function() {
            this.tree.collapseAll();
            this.ontroot.expand()
        }, n
    }(),
    OBrowserLayout = function() {
        function n() {}
        return n.prototype.initialize = function() {
            this.outerLayout = $("body").layout({
                defaults: {
                    applyDefaultStyles: !0
                },
                north: {
                    paneSelector: ".outer-north",
                    size: "85",
                    resizable: !1,
                    closable: !1,
                    spacing_closed: 0,
                    spacing_open: 0
                },
                west: {
                    paneSelector: ".outer-west",
                    size: "450",
                    resizable: !0,
                    closable: !1,
                    spacing_closed: 2,
                    spacing_open: 2
                },
                center: {
                    paneSelector: ".outer-center",
                    size: "500",
                    resizable: !0,
                    minSize: "250",
                    spacing_closed: 0,
                    spacing_open: 0,
                    onresize: "innerLayout.resizeAll"
                }
            });
            this.innerLayout = $(".outer-center").layout({
                defaults: {
                    applyDefaultStyles: !0
                },
                west: {
                    paneSelector: ".inner-west",
                    size: "850",
                    resizable: !0,
                    closable: !1,
                    spacing_closed: 2,
                    spacing_open: 2,
                    initHidden: !0,
                    onresize: function() {
                        var n = jQuery.Event("layoutResized");
                        jQuery("body").trigger(n)
                    }
                },
                center: {
                    paneSelector: ".inner-center",
                    size: "500",
                    resizable: !0,
                    minSize: "250",
                    spacing_closed: 2,
                    spacing_open: 2
                }
            });
            this.inner2Layout = $(".inner-center").layout({
                defaults: {
                    applyDefaultStyles: !0
                },
                center: {
                    paneSelector: ".inner2-center",
                    size: "500",
                    resizable: !0,
                    minSize: "250",
                    spacing_closed: 2,
                    spacing_open: 4
                },
                south: {
                    paneSelector: ".inner2-south",
                    contentSelector: "div.data",
                    size: "300",
                    resizable: !0,
                    closable: !0,
                    spacing_closed: 2,
                    spacing_open: 4,
                    togglerLength_open: 0,
                    togglerLength_closed: 0,
                    initHidden: !0
                }
            })
        }, n
    }(),
    NavigationMode;
(function(n) {
    n[n.Browser = 1] = "Browser";
    n[n.Translation = 2] = "Translation";
    n[n.Proposal = 3] = "Proposal"
})(NavigationMode || (NavigationMode = {}));
var OBrowserNavigation = function() {
        function n() {
            if (this.defaultViewBehaviour = {
                    V: {
                        defaultWhenViewIsOn: 167,
                        defaultWhenViewIsOff: 0
                    },
                    H: {
                        defaultWhenViewIsOn: 1,
                        defaultWhenViewIsOff: 1
                    },
                    G: {
                        defaultWhenViewIsOn: 0,
                        defaultWhenViewIsOff: 0
                    }
                }, n._instance) throw new Error("Error: Instantiation failed: Use OBrowserNavigation.getInstance() instead of new.");
            n._instance = this;
            this.theHierarchy = new OBrowserHierarchy;
            this.theSearcher = new OBrowserSearch;
            this.pcHierarchy = new OBrowserPCHierarchyManager;
            this.theNotificationsMgr = new OBrowserNotifications;
            this.theDetailsMgr = new OBrowserDetails;
            this.theLayout = new OBrowserLayout
        }
        return n.getInstance = function() {
            return n._instance === null && (n._instance = new n), n._instance
        }, n.prototype.initialize = function(n, t) {
            var i = this;
            if (this.oInfo = n, this.appState = t, this.defaultViewBehaviour.G.defaultWhenViewIsOff = this.appState.defaultShowGrayNodes, this.defaultViewBehaviour.G.defaultWhenViewIsOn = this.appState.defaultShowGrayNodes, this.theLayout.initialize(), this.theHierarchy.oInfo = n, this.theHierarchy.treeLocationDivId = "hierarchy", this.theHierarchy.isLinearizationInclusionIconVisible = function() {
                    return i.isViewParamValueBitSet("H", 1)
                }, this.theHierarchy.rootLabel = n.ontologyLabel, this.theHierarchy.showAdoptedChildren = function() {
                    return i.getViewParamValue("G") == 1
                }, this.getViewParamValue("G") == 1 && $("#fchld").addClass("on"), this.theHierarchy.itemClickedCallback = function(t) {
                    t == "root" ? n.rootClickURLEnding == "" ? window.location.href = n.getRootURL() : i.gotoEntity(n.rootClickURLEnding) : i.gotoEntity(t)
                }, this.theHierarchy.expandCompleteCallback = function() {}, this.theVisualizer = new OBrowserVisualizer(n), this.theSearcher.oInfo = n, this.theSearcher.quickSearchInputId = "searchbox", this.theSearcher.advancedSearchTriggerId = "advancedSearchButton", this.theSearcher.advancedSearchDivId = "advancedSearchBox", this.theSearcher.searchResultPaneId = "searchResultPane", this.theSearcher.quickSearchSelectedCallback = function(n, t) {
                    i.gotoEntity(n, t)
                }, this.theSearcher.advancedSearchResultClicked = function(n, t) {
                    i.gotoEntity(t)
                }, this.theSearcher.showAdvancedSearchResults = function() {
                    i.theLayout.inner2Layout.sizePane("south", "300");
                    i.theLayout.inner2Layout.open("south");
                    i.theLayout.inner2Layout.show("south")
                }, this.theSearcher.hideAdvancedSearchResults = function() {
                    i.theLayout.inner2Layout.close("south")
                }, this.theSearcher.initialize(), this.theNotificationsMgr.oInfo = n, this.navigationMode == NavigationMode.Translation && (this.theTranslationMgr = new OBrowserTranslations, this.theTranslationMgr.oInfo = n, this.theTranslationMgr.initialize(), this.theHierarchy.rootLabel = "Translation Home"), this.navigationMode == NavigationMode.Proposal && (this.theProposalsMgr = new OBrowserProposals, this.theProposalsMgr.oInfo = n, this.theProposalsMgr.initialize(), this.theHierarchy.rootLabel = "Proposals Home"), this.oldViewParam = "", t.appMode == "ICD10") $("body").on("contentLoaded", function(n) {
                i.theDetailsMgr.scrollAndHighlightElement(n.entityId)
            });
            this.oInfo.theLanguage == "ar" && this.setForRightToLeft();
            $("#messageArea").dialog({
                autoOpen: !1,
                buttons: {
                    Ok: function() {
                        $(this).dialog("close")
                    }
                },
                hide: "fade"
            });
            $.address.internalChange(function() {
                i.arrangeLinksInTheMenu();
                i.arangeLocationAfterLogin();
                i.hierarchyRefreshRequired() && (i.theHierarchy.initialize(), i.theHierarchy.treeSync(i.getIdFromAddressBar()));
                i.isViewParamValueBitSet("V", 0, i.oldViewParam) != i.isViewParamValueBitSet("V", 0) && (i.isViewParamValueBitSet("V", 0) ? i.arrangeViews(i.getIdFromAddressBar()) : i.arrangeViews());
                i.oldViewParam = i.getViewParam()
            });
            $.address.externalChange(function() {
                i.arrangeLinksInTheMenu();
                i.arangeLocationAfterLogin();
                i.gotoClassAtTheAddressBar()
            });
            this.oldViewParam = this.getViewParam();
            this.arrangeViews();
            $("body").on("layoutResized", function() {
                i.isVisible("V") && i.theVisualizer.visualizationResized()
            })
        }, n.prototype.fullSync = function(n) {
            var n = decodeURIComponent(n);
            this.getIdFromAddressBar() === n ? this.theHierarchy.treeSync(n) : window.location.href = "#/" + encodeURIComponent(n)
        }, n.prototype.hierarchyRefreshRequired = function() {
            var n = this.getViewParamValue("H"),
                t = this.getViewParamValue("H", this.oldViewParam);
            return n != t ? !0 : !1
        }, n.prototype.setForRightToLeft = function() {
            $("#searchbox").attr("dir", "rtl");
            $("#SearchText").attr("dir", "rtl");
            $(".inner-center").attr("dir", "rtl")
        }, n.prototype.myEncodeURIComponent = function(n) {
            return encodeURIComponent(n).replace(/%3A/g, "%3a").replace(/%2F/g, "%2f")
        }, n.prototype.toggleAdoptedChildren = function() {
            this.getViewParamValue("G") == 1 ? (this.setViewParamValue("G", 0), $("#fchld").removeClass("on"), Helper.showMessage("Additional foundation children (gray nodes) are hidden now")) : (this.setViewParamValue("G", 1), $("#fchld").addClass("on"), Helper.showMessage("Additional foundation children will be displayed in the hierarchy (in gray)"));
            this.theHierarchy.initialize();
            this.gotoClassAtTheAddressBar()
        }, n.prototype.gotoEntity = function(n, t) {
            var i = n,
                u, r;
            n.substr(4, 1) == ":" && (i = this.myEncodeURIComponent(n));
            t == undefined ? window.location.href = "#/" + i + this.getViewParamUrlComponent() : (u = this.getViewParamUrlComponent(), r = "?", u != "" && (r = "&"), window.location.href = "#/" + i + this.getViewParamUrlComponent() + r + "data=" + t)
        }, n.prototype.goAndScrollAndHighlightElement = function(n, t) {
            var i = this;
            this.loadNode(n, function() {
                i.theDetailsMgr.scrollAndHighlightElement(t)
            })
        }, n.prototype.arrangeLinksInTheMenu = function() {
            var n = this;
            $('a[id*="keepAnchor-"]').each(function(t, i) {
                var u = i.getAttribute("href"),
                    e = u.lastIndexOf("#"),
                    f, r;
                f = e > 0 ? u.substring(0, e) : u;
                r = n.getIdFromAddressBar();
                f.indexOf("/f/") > 0 && (r.indexOf("unspecified") > 0 || r.indexOf("other") > 0) && (r = r.replace(/\/[a-z]+\/(unspecified|other)/, ""));
                i.setAttribute("href", f + "#/" + r + n.getViewParamUrlComponent())
            })
        }, n.prototype.arangeLocationAfterLogin = function() {
            var t, n, i, r, u;
            t = $("#mainlogin")[0];
            t != null && (n = t.getAttribute("href"), n = n.replace("?@", "#"), i = n.lastIndexOf("#"), r = i > 0 ? n.substring(0, i) : n, u = this.getIdFromAddressBar(), t.setAttribute("href", r + "?@/" + u))
        }, n.prototype.gotoClassAtTheAddressBar = function() {
            var i = this,
                n = this.getIdFromAddressBar(),
                r, t, u;
            if (this.oInfo.ontologyId.substr(0, 5) == "ICD10" ? (r = n.split("/"), n = r[r.length - 1]) : n = OntologyBasicInfo.convertToFoundationId(n), n == "") {
                $("#details").empty();
                return
            }
            if (t = undefined, this.oInfo instanceof OntologyInfoForManualCodeAssigner) {
                this.arrangeViews(n);
                return
            }
            $.address.parameter("data") != undefined ? (u = decodeURIComponent($.address.parameter("data")), t = JSON.parse(decodeURIComponent($.address.parameter("data"))), t.dataType == "pc" && (t.postcoordinationCodeSet.stemId = OntologyBasicInfo.convertToFoundationId(t.postcoordinationCodeSet.stemId)), this.processLoadRequestData(n, t)) : this.requestPCData = new AllPostcoordinationData(n, "pc");
            this.loadNode(n, function() {
                if ($.address.parameter("showcomment") != undefined ? i.appState.userLoggedIn ? $("#commentarea_" + $.address.parameter("showcomment")).show("slow") : i.redirectToLoginWithReturnUrl() : $.address.parameter("showquestion") != undefined && (i.appState.userLoggedIn ? OBrowserContributions.getInstance().toggleQArea($.address.parameter("showquestion"), n) : i.redirectToLoginWithReturnUrl()), t != undefined && t.dataType == "uslid") {
                    var r = $("#pccsdata").attr("data-data"),
                        u = JSON.parse(r);
                    i.requestPCData = new AllPostcoordinationData(n, "pc");
                    i.requestPCData.postcoordinationCodeSet.copyFromClone(u.postcoordinationCodeSet)
                }
            }, t)
        }, n.prototype.processLoadRequestData = function(n, t) {
            (t.dataType == "pc" || t.dataType == "uslid") && t.dataType == "pc" && (this.requestPCData = new AllPostcoordinationData(n, t.dataType), this.requestPCData.postcoordinationCodeSet.copyFromClone(t.postcoordinationCodeSet))
        }, n.prototype.updateDataInTheUrl = function(n) {
            var t = JSON.stringify(n),
                i = encodeURIComponent(t);
            this.setAddressParam("data", i)
        }, n.prototype.updatePCDataInTheUrl = function() {
            this.updateDataInTheUrl(this.requestPCData)
        }, n.prototype.redirectToLoginWithReturnUrl = function() {
            var n = window.location.href,
                t, i;
            n = n.replace("#", "?@");
            n.substr(0, 7) == "http://" && (n = n.substr(7, n.length - 7));
            t = n.indexOf("/");
            n = n.substr(t, n.length - t);
            i = this.oInfo.baseURL + "Account/LogIn?returnUrl=" + n;
            window.location.href = i
        }, n.prototype.getIdFromAddressBar = function() {
            var n = $.address.path(),
                t;
            return t = n.substr(0, 3) == "/!/" ? n.substr(3, n.length - 3) : n.substr(0, 2) == "/!" ? n.substr(2, n.length - 2) : n.substr(1, n.length - 1), decodeURIComponent(t)
        }, n.prototype.setAddressParam = function(n, t) {
            $.address.parameter(n, t)
        }, n.prototype.getViewParam = function() {
            var n = $.address.parameter("view");
            return n == undefined && (n = ""), n
        }, n.prototype.setViewParam = function(n) {
            $.address.parameter("view", n)
        }, n.prototype.isViewParamValueBitSet = function(n, t, i) {
            var r = this.getViewParamValue(n, i);
            return (r & Math.pow(2, t)) > 0
        }, n.prototype.setViewParamValueBit = function(n, t) {
            var i = this.getViewParamValue(n),
                r = i | Math.pow(2, t);
            this.setViewParamValue(n, r)
        }, n.prototype.resetViewParamValueBit = function(n, t) {
            var i = this.getViewParamValue(n),
                r = i & Math.pow(2, 32) - 1 - Math.pow(2, t);
            this.setViewParamValue(n, r)
        }, n.prototype.toggleView = function(t) {
            n.getInstance().getViewParam().indexOf(t) == -1 ? n.getInstance().setViewParamValue("V", this.defaultViewBehaviour[t].defaultWhenViewIsOn) : this.toggleViewParamValueBit(t, 0)
        }, n.prototype.toggleViewParamValueBit = function(n, t) {
            this.isViewParamValueBitSet(n, t) ? this.resetViewParamValueBit(n, t) : this.setViewParamValueBit(n, t)
        }, n.prototype.getViewParamValue = function(n, t) {
            if (t == undefined && (t = this.getViewParam()), t.indexOf(n) == -1) return this.defaultViewBehaviour[n].defaultWhenViewIsOff;
            var r = new RegExp(n + "([0-9]*)"),
                i = r.exec(t);
            return i == null ? 0 : i[1] == "" ? 0 : parseInt(i[1]) == NaN ? 0 : parseInt(i[1])
        }, n.prototype.setViewParamValue = function(n, t) {
            var i = this.getViewParam();
            i.indexOf(n) == -1 && (i = i + n);
            var r = "^([^" + n + "]*)" + n + "([0-9]*)(.*)$",
                u = new RegExp(r),
                e = u.exec(i),
                f = i.replace(new RegExp(r), "$1" + n + t + "$3");
            this.setViewParam(f)
        }, n.prototype.getViewParamUrlComponent = function() {
            var n = "";
            return this.getViewParam() != "" && (n = "?view=" + this.getViewParam()), n
        }, n.prototype.isVisible = function(n, t) {
            t != undefined && (i = t);
            var i = $.address.parameter("view");
            return i == undefined || i.indexOf(n) == -1 ? (this.defaultViewBehaviour[n].defaultWhenViewIsOff & 1) != 0 : this.isViewParamValueBitSet(n, 0) ? !0 : !1
        }, n.prototype.isVisualizationVisible = function() {
            return this.isVisible("V")
        }, n.prototype.isHierarchyVisible = function() {
            return this.isVisible("H")
        }, n.prototype.arrangeViews = function(n) {
            this.isVisualizationVisible() ? (this.theLayout.innerLayout.show("west"), this.theVisualizer.visualizationSync(n)) : this.theLayout.innerLayout.hide("west");
            this.isHierarchyVisible() ? (this.theLayout.outerLayout.show("west"), this.theHierarchy.treeSync(n)) : this.theLayout.outerLayout.hide("west")
        }, n.prototype.loadNode = function(n, t, i) {
            this.loadContent(n, t, i);
            this.arrangeViews(n)
        }, n.prototype.reloadContent = function(n, t) {
            var i = this.getIdFromAddressBar();
            this.loadContent(i, n, t)
        }, n.prototype.loadContent = function(n, t, i) {
            var f = jQuery.Event("contentLoading"),
                r, u, e;
            if (jQuery("body").trigger(f), !f.isDefaultPrevented()) {
                if (n != this.getIdFromAddressBar() && $.address.path(n), n == this.oInfo.ontologyKey) return;
                this.closeAllDialogs();
                r = this.oInfo.rightLoadURL(n, i);
                $("#conceptdetailswaitimg").show();
                $("#firstright :input").attr("disabled", "true");
                $("#firstright *").removeAttr("onclick");
                r[0] == "#" ? (u = $("#firstright"), e = $(r), u.animate({
                    scrollTop: e.offset().top - u.offset().top + u.scrollTop()
                })) : $("#firstright").load(r, function() {
                    typeof t == "function" && t();
                    var i = jQuery.Event("contentLoaded", {
                        entityId: n
                    });
                    jQuery("body").trigger(i);
                    ga("send", "pageview", {
                        page: Helper.getAllButHostName(r),
                        title: "ICD-11 Browser :" + n
                    })
                })
            }
        }, n.prototype.closeAllDialogs = function() {
            $(".tobedestroyed").remove();
            $(".popup").remove();
            $(".popup2bclosed").remove()
        }, n.prototype.openQuestion = function(t) {
            n.getInstance().setAddressParam("showquestion", t);
            n.getInstance().gotoClassAtTheAddressBar()
        }, n.prototype.showHistoryFor = function(n) {
            var t = this.oInfo.getRootURL() + "/GetHistory?conceptID=" + n;
            $("#showinpopupdiv").empty();
            Helper.showInPopup(t, 100, 100, 780, 700, "Change History", this.oInfo.baseURL + "/Content/wait.gif", "showinpopudiv", "historydlg")
        }, n._instance = null, n
    }(),
    OBrowserNotifications = function() {
        function n() {}
        return n.prototype.addNotification = function(n, t, i) {
            var u = this,
                r, f;
            $("#notificationdomainsarea").is(":data(dialog)") || $("#notificationdomainsarea").dialog({
                autoOpen: !1,
                show: "fade",
                hide: "fade",
                width: "650",
                height: "650",
                buttons: {
                    Close: function() {
                        $(this).dialog("close")
                    }
                }
            });
            r = $("<div><p>Would you like to add this entity in to your notification domains?<\/p><p>You receive email notifications when there are new comments in this entity or any of its descendants<\/p><\/div>").dialog({
                autoOpen: !0,
                show: "fade",
                hide: "fade",
                width: "500",
                height: "300",
                buttons: {
                    Add: function() {
                        var i = {};
                        i.entityid = t;
                        r.dialog("close");
                        $.post(u.oInfo.baseURL + "user/addtonotificationdomains/" + u.oInfo.ontologyKey.toLowerCase() + "/" + n, i, function(n) {
                            $("#notificationdomainsarea").html(n).dialog("open")
                        })
                    },
                    "Show/Manage my notification domains": function() {
                        r.dialog("close");
                        $.get(u.oInfo.baseURL + "user/notificationdomains/" + u.oInfo.ontologyKey.toLowerCase() + "/" + n, function(n) {
                            $("#notificationdomainsarea").html(n).dialog("open")
                        })
                    },
                    Cancel: function() {
                        r.dialog("close")
                    }
                }
            });
            i == !1 && (f = r.dialog("option", "buttons"), delete f.Add, r.dialog("option", "buttons", f), r.html("<div>You don't need to add this entity in to your notifocation domains as this entity or one of its ancestors is already in your notification domains.<br/> You will be receiving notification emails if there is new activity at this entity.<\/div>"))
        }, n.prototype.deleteNotificationClicked = function(n, t) {
            var i = {};
            i.entityid = t;
            $.post(this.oInfo.baseURL + "user/deletenotificationdomain/" + this.oInfo.ontologyKey.toLowerCase() + "/" + n, i, function(n) {
                $("#notificationdomainsarea").html(n)
            })
        }, n
    }(),
    OCTEntity = function() {
        function n(n) {
            this.children = [];
            this.parents = [];
            $.extend(this, n)
        }
        return n.prototype.localDepth = function() {
            for (var n = this.parents[0], t = 1; n != null;) n = n.parents[0], t++;
            return t
        }, n.prototype.addChild = function(n) {
            return _.findWhere(this.children, {
                ID: n.ID
            }) == undefined ? (this.children.push(n), !0) : !1
        }, n.prototype.addParent = function(n) {
            return _.findWhere(this.parents, {
                ID: n.ID
            }) == undefined ? (this.parents.push(n), !0) : !1
        }, n.prototype.linearizationParent = function(n) {
            var t = _.findWhere(this.linearizationInformation, {
                linearizationName: n
            });
            return t == undefined ? null : _.findWhere(this.parents, {
                ID: t.parentId
            })
        }, n
    }(),
    OCTEntities = function() {
        function n() {
            this.entities = [];
            this.rootEntities = []
        }
        return n.prototype.addEntity = function(n) {
            var t = this.getEntityByID(n.ID);
            return t != undefined ? t : (this.entities.push(n), n)
        }, n.prototype.getEntityByID = function(n) {
            return _.findWhere(this.entities, {
                ID: n
            })
        }, n.prototype.initialize = function() {
            var n = 0,
                t = 99999;
            this.entities.forEach(function(i) {
                var r = i.localDepth();
                r > n && (n = r);
                r < t && (t = r)
            });
            this._maxDepth = n;
            this._minDepth = t
        }, n
    }(),
    PostcoordinationCodeSet = function() {
        function n(n) {
            this.stemId = n
        }
        return n.prototype.copyFromClone = function(t) {
            var r, u, s, i, f, e, o;
            this.stemId = t.stemId;
            this.axisToValueIds = {};
            for (r in t.axisToValueIds)
                for (u = [], this.axisToValueIds[r] = u, s = t.axisToValueIds[r], i = 0, f = s; i < f.length; i++) e = f[i], o = new n(e.stemId), u.push(o), o.copyFromClone(e)
        }, n.prototype.addPCValueOnThisIfFirst = function(t, i) {
            if (this.axisToValueIds == undefined && (this.axisToValueIds = {}), this.axisToValueIds[t] != undefined) return _.filter(this.axisToValueIds[t], function(n) {
                return n.stemId == i
            }).length == 0 ? !1 : !0;
            this.axisToValueIds[t] = [];
            var r = new n(i);
            return this.axisToValueIds[t].push(r), !0
        }, n.prototype.addPCValueIfFirst = function(n, t, i) {
            var r = this.getPostcoordinationCodeSet(OntologyBasicInfo.convertToFoundationId(n));
            return r != null ? r.addPCValueOnThisIfFirst(t, OntologyBasicInfo.convertToFoundationId(i)) : !1
        }, n.prototype.getPostcoordinationCodeSet = function(n) {
            var u, t, i, f, r;
            if (this.stemId == n) return this;
            for (u in this.axisToValueIds)
                for (t = 0, i = this.axisToValueIds[u]; t < i.length; t++)
                    if (f = i[t], r = f.getPostcoordinationCodeSet(n), r != null) return r;
            return null
        }, n.prototype.isAxisSingleCardinality = function(n) {
            return n == "associatedWith" ? !1 : !0
        }, n.prototype.removePCValue = function(n, t, i) {
            var r = this.getPostcoordinationCodeSet(n);
            r != null && r.removePCValueOnThis(t, i)
        }, n.prototype.removePCValueOnThis = function(n, t) {
            var r, i;
            if (this.axisToValueIds[n] != undefined) {
                for (r = -1, i = 0; i < this.axisToValueIds[n].length; ++i)
                    if (this.axisToValueIds[n][i].stemId == t) {
                        r = i;
                        break
                    } this.axisToValueIds[n].splice(r, 1);
                this.axisToValueIds[n].length == 0 && delete this.axisToValueIds[n]
            }
        }, n.prototype.addMethodsToSerializedObjects = function() {
            var r, u, t, i, f;
            if (this.axisToValueIds != null)
                for (r in this.axisToValueIds)
                    for (u = function(t) {
                            Object.getOwnPropertyNames(n.prototype).forEach(function(i) {
                                t[i] = n.prototype[i]
                            });
                            t.addMethodsToSerializedObjects()
                        }, t = 0, i = this.axisToValueIds[r]; t < i.length; t++) f = i[t], u(f)
        }, n
    }(),
    AllPostcoordinationData = function() {
        function n(n, t) {
            this.dataType = t;
            this.postcoordinationCodeSet = new PostcoordinationCodeSet(n)
        }
        return n.prototype.addPCValue = function(n, t, i) {
            var r = this,
                u;
            if (n = OntologyBasicInfo.convertToFoundationId(n), i = OntologyBasicInfo.convertToFoundationId(i), this.postcoordinationCodeSet.addPCValueIfFirst(n, t, i)) {
                OBrowserNavigation.getInstance().updatePCDataInTheUrl();
                this.getPCSummary();
                return
            }
            u = OBrowserNavigation.getInstance().oInfo.getDetailsURL(OBrowserNavigation.getInstance().getIdFromAddressBar(), this).replace("GetConcept", "GetUpdatedPostCoordinationData") + "&stemId=" + n + "&newValueAxis=" + t + "&newValueId=" + i;
            $.post(u, function(n) {
                r.postcoordinationCodeSet.axisToValueIds = JSON.parse(n).postcoordinationCodeSet.axisToValueIds;
                r.postcoordinationCodeSet.addMethodsToSerializedObjects();
                OBrowserNavigation.getInstance().updatePCDataInTheUrl();
                r.getPCSummary()
            })
        }, n.prototype.removePCValue = function(n, t, i) {
            this.postcoordinationCodeSet.removePCValue(n, t, i);
            OBrowserNavigation.getInstance().updatePCDataInTheUrl();
            this.getPCSummary()
        }, n.prototype.isAxisSingleCardinality = function(n) {
            return n == "associatedWith" ? !1 : !0
        }, n.prototype.getPCSummary = function() {
            var n = OBrowserNavigation.getInstance().oInfo.getDetailsURL(OBrowserNavigation.getInstance().getIdFromAddressBar(), this).replace("GetConcept", "GetPostCoordination");
            $("#pcsummaryi").load(n, function() {
                OBrowserNavigation.getInstance().theSearcher.initializePostcoordinationSearch(!0)
            })
        }, n
    }(),
    VSProposal = function() {
        function n() {}
        return n
    }(),
    OBrowserPCHierarchyManager = function() {
        function n() {
            this.valuesProposedForAddition = {};
            this.valuesProposedForRemoval = {};
            this.unchangedValueSetValues = {};
            this.initializedPerAxis = {}
        }
        return n.prototype.openSubtree = function(n, t, i, r, u, f, e, o, s, h) {
            var c = this,
                a, v, l;
            o === void 0 && (o = !1);
            s === void 0 && (s = "TreeViewItem");
            a = encodeURIComponent(r);
            n = encodeURIComponent(n);
            o && (this.populateProposalInfo(i), this.unchangedValueSetValues[i] = JSON.parse(h));
            this.pcHierarchy = new OBrowserHierarchy;
            this.pcHierarchy.treeLocationDivId = "tree_" + u;
            this.pcHierarchy.oInfo = new OntologyBasicInfo;
            this.pcHierarchy.oInfo.ontologyKey = OBrowserNavigation.getInstance().oInfo.ontologyKey;
            this.pcHierarchy.oInfo.ontologyId = OBrowserNavigation.getInstance().oInfo.ontologyId;
            this.pcHierarchy.oInfo.theLanguage = OBrowserNavigation.getInstance().oInfo.theLanguage;
            this.pcHierarchy.oInfo.isLinearization = OBrowserNavigation.getInstance().oInfo.isLinearization;
            this.pcHierarchy.oInfo.baseURL = OBrowserNavigation.getInstance().oInfo.baseURL;
            this.pcHierarchy.oInfo.ontologyLabel = OBrowserNavigation.getInstance().oInfo.ontologyLabel;
            this.pcHierarchy.oInfo.usesElastic = OBrowserNavigation.getInstance().oInfo.usesElastic;
            this.pcHierarchy.oInfo.getChildrenConceptsURLForTreeRendering = function(n, t) {
                return c.pcHierarchy.oInfo.getRootURL() + "/JsonGetChildrenConcepts?ConceptId=" + n + "&useHtml=true&showAdoptedChildren=" + t + "&itemViewName=" + s
            };
            this.pcHierarchy.oInfo.getRootConceptsURLForTreeRendering = function() {
                return c.pcHierarchy.oInfo.getRootURL() + "/JsonGetPCAxisRoot?ConceptId=" + a + "&useHtml=true&axisName=" + n + "&fullAxis=" + o + "&itemViewName=" + s
            };
            this.pcHierarchy.showAdoptedChildren = function() {
                return e
            };
            this.pcHierarchy.isLinearizationInclusionIconVisible = function() {
                return !1
            };
            this.pcHierarchy.rootLabel = t;
            o ? (this.pcHierarchy.itemClickedCallback = function() {}, this.pcHierarchy.expandCompleteCallback = function() {
                c.refreshTree(i)
            }) : this.pcHierarchy.itemClickedCallback = function(n) {
                OBrowserNavigation.getInstance().requestPCData.addPCValue(r, i, n)
            };
            this.pcHierarchy.initialize();
            o && this.unchangedValueSetValues[i] != null && this.unchangedValueSetValues[i][0] != null && (v = this.unchangedValueSetValues[i][0], setTimeout(function() {
                c.pcHierarchy.treeSync(v)
            }, 100));
            o || (l = !1, $("#" + u).hasClass("ui-dialog-content") && (l = !0), l || $("#" + u).dialog({
                title: t,
                height: "400",
                width: "500",
                position: {
                    my: "left top",
                    at: "right+41 top",
                    of: "#" + f,
                    collision: "fit"
                },
                autoOpen: !1
            }), $("#" + u).dialog("open"))
        }, n.prototype.populateProposalInfo = function(n) {
            var t = this;
            this.valuesProposedForAddition[n] = [];
            this.valuesProposedForRemoval[n] = [];
            $("[name^=valuesProposedForAddition-" + n + "\\[]").each(function(i, r) {
                var u, f, e, o, s;
                r.id.substr(r.id.length - 19) != "_ContributionStatus" && (u = new VSProposal, u.id = r.value, f = r.id.replace("valuesProposedForAddition", "valuesProposedForAdditionContribId"), e = $("#" + f), u.contributionId = e.val(), u.isNew = !1, o = r.id.replace("valuesProposedForAddition", "valuesProposedForAdditionTitle"), s = $("#" + o), u.title = s.val(), t.valuesProposedForAddition[n].push(u))
            });
            $("[name^=valuesProposedForDeletion-" + n + "\\[]").each(function(i, r) {
                var u, f, e, o, s;
                r.id.substr(r.id.length - 19) != "_ContributionStatus" && (u = new VSProposal, u.id = r.value, f = r.id.replace("valuesProposedForDeletion", "valuesProposedForDeletionContribId"), e = $("#" + f), u.contributionId = e.val(), u.isNew = !1, o = r.id.replace("valuesProposedForDeletion", "valuesProposedForDeletionTitle"), s = $("#" + o), u.title = s.val(), t.valuesProposedForRemoval[n].push(u))
            })
        }, n.prototype.refreshTree = function(n) {
            var t = this,
                i = $("#tree_" + n + " .tvi"),
                r = $(".tvi"),
                u = i.length,
                f = r.length;
            $(".tvi").each(function(i, r) {
                var f = r.getAttribute("data-id"),
                    e, u;
                if (console.log(f), e = r.getAttribute("data-title"), u = "#tree_" + n + " .visid_" + f.replace("http://id.who.int/icd/entity/", ""), !(u.indexOf("/") >= 0))
                    if (t.containsInUnchangedValuesetValues(f, t.unchangedValueSetValues[n]))
                        if (t.doesNotContain(f, t.valuesProposedForRemoval[n])) {
                            $(u).text("☑");
                            $(u).removeClass("additionsuggested");
                            $(u).removeClass("removalsuggested");
                            $(u).addClass("includedunchanged");
                            $(u).unbind("click");
                            $(u).on("click", function() {
                                return t.toggleValueSet(u, n, f, e)
                            })
                        } else {
                            $(u).text("☒");
                            $(u).removeClass("additionsuggested");
                            $(u).addClass("removalsuggested");
                            $(u).removeClass("includedunchanged");
                            $(u).unbind("click");
                            $(u).on("click", function() {
                                return t.toggleValueSet(u, n, f, e)
                            })
                        }
                else if (t.contains(f, t.valuesProposedForAddition[n])) {
                    $(u).text("☑");
                    $(u).addClass("additionsuggested");
                    $(u).removeClass("removalsuggested");
                    $(u).removeClass("includedunchanged");
                    $(u).unbind("click");
                    $(u).on("click", function() {
                        return t.toggleValueSet(u, n, f, e)
                    })
                } else if (t.contains(f, t.valuesProposedForRemoval[n])) {
                    $(u).text("☒");
                    $(u).removeClass("additionsuggested");
                    $(u).addClass("removalsuggested");
                    $(u).removeClass("includedunchanged");
                    $(u).unbind("click");
                    $(u).on("click", function() {
                        return t.toggleValueSet(u, n, f, e)
                    })
                } else {
                    $(u).text("☐");
                    $(u).removeClass("additionsuggested");
                    $(u).removeClass("removalsuggested");
                    $(u).removeClass("includedunchanged");
                    $(u).unbind("click");
                    $(u).on("click", function() {
                        return t.toggleValueSet(u, n, f, e)
                    })
                }
            })
        }, n.prototype.toggleValueSet = function(n, t, i, r) {
            var f = this,
                u;
            $(n).text() == "☑" ? this.removeFromValueSet(t, i, r) : ($(n).text() == "☒" || $(n).text() == "☐") && this.addToValueSet(t, i, r);
            u = this.getValueSetValuesForPosting(t);
            $("#valueset-" + t).empty();
            OBrowserNavigation.getInstance().theProposalsMgr.submitProposal(ProposalSubmitTypeEnum.Save, u, !1, function(n) {
                f.placeUpdatedValuesetValues(t, n)
            })
        }, n.prototype.addToValueSet = function(n, t, i) {
            if (this.doesNotContainUnchangedValuesetValues(t, this.unchangedValueSetValues[n]) && this.doesNotContain(t, this.valuesProposedForAddition[n])) {
                this.valuesProposedForAddition[n] == undefined && (this.valuesProposedForAddition[n] = []);
                var r = new VSProposal;
                r.id = t;
                r.title = i;
                r.isNew = !0;
                this.valuesProposedForAddition[n].push(r)
            } else this.containsInUnchangedValuesetValues(t, this.unchangedValueSetValues[n]) && this.contains(t, this.valuesProposedForRemoval[n]) && (this.valuesProposedForRemoval[n] = this.valuesProposedForRemoval[n].filter(function(n) {
                return n.id != t
            }));
            this.refreshTree(n)
        }, n.prototype.removeFromValueSet = function(n, t, i) {
            if (this.doesNotContainUnchangedValuesetValues(t, this.unchangedValueSetValues[n]) && this.contains(t, this.valuesProposedForAddition[n])) this.valuesProposedForAddition[n] = this.valuesProposedForAddition[n].filter(function(n) {
                return n.id != t
            });
            else if (this.containsInUnchangedValuesetValues(t, this.unchangedValueSetValues[n]) && this.doesNotContain(t, this.valuesProposedForRemoval[n])) {
                this.valuesProposedForRemoval[n] == undefined && (this.valuesProposedForRemoval[n] = []);
                var r = new VSProposal;
                r.id = t;
                r.title = i;
                r.isNew = !0;
                this.valuesProposedForRemoval[n].push(r)
            }
            this.refreshTree(n)
        }, n.prototype.containsInUnchangedValuesetValues = function(n, t) {
            return t == undefined ? !1 : t.indexOf(n) >= 0
        }, n.prototype.doesNotContainUnchangedValuesetValues = function(n, t) {
            return t == undefined ? !0 : t.indexOf(n) < 0
        }, n.prototype.contains = function(n, t) {
            return t == undefined ? !1 : t.filter(function(t) {
                return t.id == n
            }).length > 0
        }, n.prototype.doesNotContain = function(n, t) {
            return t == undefined ? !0 : t.filter(function(t) {
                return t.id == n
            }).length <= 0
        }, n.prototype.placeUpdatedValuesetValues = function(n, t) {
            OBrowserNavigation.getInstance().theProposalsMgr.refreshValueSetList(n, t, function(t) {
                $("#valueset-" + n).html(t)
            })
        }, n.prototype.getValueSetValuesForPosting = function(n) {
            var t = "";
            return this.valuesProposedForAddition[n] != undefined && this.valuesProposedForAddition[n].forEach(function(i, r) {
                t = t.concat("&valuesProposedForAddition-" + n + "[" + r + "]=" + i.id);
                i.contributionId != null && (t = t.concat("&valuesProposedForAdditionContribId-" + n + "[" + r + "]=" + i.contributionId))
            }), this.valuesProposedForRemoval[n] != undefined && this.valuesProposedForRemoval[n].forEach(function(i, r) {
                t = t.concat("&valuesProposedForDeletion-" + n + "[" + r + "]=" + i.id);
                i.contributionId != null && (t = t.concat("&valuesProposedForDeletionContribId-" + n + "[" + r + "]=" + i.contributionId))
            }), t
        }, n
    }(),
    OBrowserSearch = function() {
        function n() {}
        return n.prototype.initialize = function() {
            var n = this;
            this.oInfo.usesElastic ? (this.initalizeSearchAutoComplete2(), this.initializeAdvancedSearchBox(function() {
                return n.submitAdvancedSearch2()
            })) : (this.initalizeSearchAutoComplete(), this.initializeAdvancedSearchBox(function() {
                return n.submitAdvancedSearch()
            }));
            $("body").on("contentLoaded", function() {
                n.initializePostcoordinationSearch(!1)
            })
        }, n.prototype.myEncodeURIComponent = function(n) {
            return encodeURIComponent(n).replace(/%3A/g, "%3a").replace(/%2F/g, "%2f")
        }, n.prototype.initalizeSearchAutoComplete = function() {
            var n = this,
                t = 3,
                i, r;
            (this.oInfo.theLanguage == "ja" || this.oInfo.theLanguage == "ko" || this.oInfo.theLanguage == "zh" || this.oInfo.theLanguage == "zh-Hant") && (t = 2);
            i = this.oInfo.baseURL + this.oInfo.ontologyKey.toLowerCase() + "/" + this.oInfo.theLanguage + "/Search";
            r = $("#" + this.quickSearchInputId).attr("data-searchtype");
            $("#" + this.quickSearchInputId).autocomplete({
                source: function(t, u) {
                    var f = i + "?q=" + encodeURIComponent(t.term) + "&searchtype=" + r,
                        e;
                    n.lastSearchedText = t.term;
                    e = $.get(f, function(n) {
                        u(n)
                    })
                },
                select: function(t, i) {
                    if (t.preventDefault(), i.item.id != "DummyID") n.quickSearchSelectedCallback(i.item.id), typeof ga != "undefined" && ga("send", "event", "search", "searchasyoutypeclickresult", n.lastSearchedText + ":" + i.item.id);
                    else {
                        var r = $("#searchbox")[0].value;
                        r.substr(-1) != "*" && (r = r + "*");
                        n.advancedSearch(r)
                    }
                },
                focus: function(n) {
                    n.preventDefault()
                },
                minLength: t,
                delay: 1e3,
                html: !0
            })
        }, n.prototype.initalizeSearchAutoComplete2 = function() {
            var n = this,
                i = 3;
            (this.oInfo.theLanguage == "ja" || this.oInfo.theLanguage == "ko" || this.oInfo.theLanguage == "zh" || this.oInfo.theLanguage == "zh-Hant") && (i = 2);
            var r = this.oInfo.baseURL + this.oInfo.ontologyKey.toLowerCase() + "/" + this.oInfo.theLanguage + "/ACSearch",
                u = this,
                t = !0;
            $("#" + this.quickSearchInputId).focus(function() {
                t && ($(".ui-autocomplete").position({
                    my: "left top",
                    at: "left bottom+1",
                    of: $("#" + n.quickSearchInputId),
                    collision: "none"
                }), t = !1);
                var i = $(".ui-autocomplete .oneentity").length;
                i > 0 && $(".ui-autocomplete").show()
            });
            $("#" + this.quickSearchInputId).click(function() {
                t && ($(".ui-autocomplete").position({
                    my: "left top",
                    at: "left bottom+1",
                    of: $("#" + n.quickSearchInputId),
                    collision: "none"
                }), t = !1);
                var i = $(".ui-autocomplete .oneentity").length;
                i > 0 && $(".ui-autocomplete").show()
            });
            $("#" + this.quickSearchInputId).autocomplete({
                source: function(t) {
                    var e = r + "?q=" + encodeURIComponent(t.term),
                        i, f;
                    n.lastSearchedText = t.term;
                    i = {};
                    i.q = t.term;
                    f = n.quickSearchInputId;
                    $(".searchwait").fadeIn(400);
                    $.post(r, i).done(function(n) {
                        var i = this,
                            t = $(".outer-west").innerHeight();
                        $(".ui-autocomplete").html(n);
                        t < 600 ? $(".ui-autocomplete").css("max-height", t) : $(".ui-autocomplete").css("max-height", 600);
                        $(".ui-autocomplete").show();
                        $(".ui-autocomplete").position({
                            my: "left top",
                            at: "left bottom+1",
                            of: $("#" + f),
                            collision: "none"
                        });
                        $(".searchwait").hide();
                        u.linkSearchResult(u, function(n) {
                            $(".ui-autocomplete").hide();
                            typeof ga != "undefined" && ga("send", "event", "search", "searchasyoutypeclickresult", i.lastSearchedText + ":" + n)
                        })
                    })
                },
                select: function(n) {
                    n.preventDefault()
                },
                focus: function(n) {
                    n.preventDefault()
                },
                minLength: i,
                delay: 1e3
            })
        }, n.prototype.linkSearchResult = function(n, t) {
            $(".searchresults .elink").click(function(i) {
                var r = $(i.currentTarget).attr("data-stemid"),
                    u = $(i.currentTarget).attr("data-data"),
                    f = $(i.currentTarget).attr("data-undershorelineid"),
                    e, o;
                f != null ? (e = {
                    dataType: "uslid",
                    underShorlineId: f
                }, o = encodeURIComponent(JSON.stringify(e)), n.quickSearchSelectedCallback(r, o)) : u != null ? n.quickSearchSelectedCallback(r, encodeURIComponent(u)) : n.quickSearchSelectedCallback(r);
                t(r)
            })
        }, n.prototype.onTextClick = function(n) {
            var t = $("#" + n);
            t.prop("checked", !t.prop("checked"))
        }, n.prototype.initializeAdvancedSearchBox = function(n) {
            var t = this,
                i, r;
            $("#" + this.advancedSearchTriggerId).on("click", function() {
                t.advancedSearch(t.lastSearchedText)
            });
            $("body").on("click", ".ui-icon.close", function() {
                t.hideAdvancedSearchResults()
            });
            $("body").on("click", ".advancedsearchresult", function(n) {
                var i = n.target.getAttribute("data-conceptid"),
                    r = n.target.getAttribute("data-ontologyid");
                t.advancedSearchResultClicked(r, i)
            });
            $("#" + this.advancedSearchDivId).dialog({
                autoOpen: !1,
                open: function() {
                    $("#" + t.advancedSearchDivId).keypress(function(t) {
                        if (t.keyCode == $.ui.keyCode.ENTER) return n(), !1
                    })
                },
                close: function() {
                    $(".ui-tooltip").hide()
                },
                show: "slide",
                hide: "slide",
                title: $("#" + this.advancedSearchTriggerId)[0].innerText,
                buttons: [{
                    text: "Search",
                    click: function() {
                        n()
                    }
                }],
                position: [5, 100],
                width: 540
            });
            $("#" + this.advancedSearchDivId + " form").bind("keyup", function(n) {
                var t = n.keyCode || n.which;
                if (t == 13) return n.preventDefault(), !1
            });
            i = $("body").height();
            r = i * .6;
            $(".advsearchpropertiesdiv").css({
                "max-height": r + "px"
            })
        }, n.prototype.initializePostcoordinationSearch = function(n) {
            var t = this.oInfo.baseURL + this.oInfo.ontologyKey.toLowerCase() + "/" + this.oInfo.theLanguage + "/ACSearch";
            $(".pcsearch").each(function() {
                var e = OBrowserNavigation.getInstance().getIdFromAddressBar(),
                    i = $(this),
                    o = i.attr("id"),
                    s = i.attr("data-axisName"),
                    f = i.attr("data-stemId"),
                    u, r;
                e == f && n || (u = JSON.parse(i.attr("data-scaleentities")), r = "#" + i.attr("data-resultelementid"), $(r).dialog({
                    title: "Search results " + i.attr("data-readableAxisName"),
                    height: "400",
                    width: "500",
                    position: {
                        my: "left top",
                        at: "right+1 top",
                        of: "#" + o,
                        collision: "fit"
                    },
                    autoOpen: !1
                }), i.autocomplete({
                    appendTo: r,
                    source: function(n) {
                        var e = u,
                            i = {};
                        i.q = n.term;
                        i.scaleEntities = u;
                        $.post(t, i).done(function(n) {
                            var t = $(":focus");
                            $(r).html(n);
                            $(r).dialog("open");
                            t.focus();
                            $(".searchresults .elink").click(function() {
                                var n = $(this).attr("data-stemid");
                                OBrowserNavigation.getInstance().requestPCData.addPCValue(f, s, n)
                            })
                        })
                    },
                    select: function(n) {
                        n.preventDefault()
                    },
                    focus: function(n) {
                        n.preventDefault()
                    },
                    minLength: 3,
                    delay: 1e3
                }))
            })
        }, n.showPropertyValues = function(n) {
            $(".pvsdetails_" + n).toggle()
        }, n.prototype.submitAdvancedSearch = function() {
            var n = this,
                t, i;
            $(".ui-dialog-buttonpane button:contains('Search')").button("disable");
            $(".searchresultwaitimg").show();
            $("#" + this.searchResultPaneId + " .searchResultDiv").empty();
            t = this.oInfo.baseURL + this.oInfo.ontologyKey.toLowerCase() + "/" + this.oInfo.theLanguage + "/AdvancedSearch";
            this.lastSearchedText = $("#" + this.advancedSearchDivId + " .advancedSearchTextBox").val();
            i = $("#" + this.advancedSearchDivId + " form").serialize();
            $.post(t, i).done(function(t) {
                $("#" + n.searchResultPaneId).html(t);
                $(".ui-dialog-buttonpane button:contains('Search')").button("enable");
                ga("send", "event", "search", "advancedsearch", n.lastSearchedText)
            }).fail(function() {
                $("#" + n.searchResultPaneId + " .searchResultDiv").text("Error occurred! Please try again later");
                $(".ui-dialog-buttonpane button:contains('Search')").button("enable");
                ga("send", "exception", {
                    exDescription: "Error in advanced search while searching for:" + n.lastSearchedText,
                    exFatal: !1
                })
            });
            this.showAdvancedSearchResults()
        }, n.prototype.submitAdvancedSearch2 = function() {
            var n = this,
                i, r, t;
            $(".ui-dialog-buttonpane button:contains('Search')").button("disable");
            $(".searchresultwaitimg").show();
            $("#" + this.searchResultPaneId + " .searchResultDiv").empty();
            i = this.oInfo.baseURL + this.oInfo.ontologyKey.toLowerCase() + "/" + this.oInfo.theLanguage + "/AdvancedSearch2";
            this.lastSearchedText = $("#" + this.advancedSearchDivId + " .advancedSearchTextBox").val();
            r = $("#" + this.advancedSearchDivId + " form").serialize();
            t = this;
            $.post(i, r).done(function(i) {
                $("#" + n.searchResultPaneId).html(i);
                $(".ui-dialog-buttonpane button:contains('Search')").button("enable");
                t.linkSearchResult(t, function() {
                    $(".ui-autocomplete").hide();
                    typeof ga != "undefined" && ga("send", "event", "search", "advancedsearch", n.lastSearchedText)
                })
            }).fail(function() {
                $("#" + n.searchResultPaneId + " .searchResultDiv").text("Error occurred! Please try again later");
                $(".ui-dialog-buttonpane button:contains('Search')").button("enable");
                ga("send", "exception", {
                    exDescription: "Error in advanced search while searching for:" + n.lastSearchedText,
                    exFatal: !1
                })
            });
            this.showAdvancedSearchResults()
        }, n.prototype.openAdvancedSearch = function() {
            $(".ui-autocomplete").hide();
            this.advancedSearch(this.lastSearchedText)
        }, n.prototype.advancedSearch = function(n) {
            $("#" + this.advancedSearchDivId).dialog("isOpen") ? $("#" + this.advancedSearchDivId).dialog("close") : ($("#" + this.advancedSearchDivId).dialog("open"), n != undefined && $("#" + this.advancedSearchDivId + " .advancedSearchTextBox").val(n))
        }, n
    }(),
    VisualizationOptions = function() {
        function n() {
            this.loadChildren = !0;
            this.loadParents = !0;
            this.includeAllAncestors = !1;
            this.loadAllAncestorsOfChildren = !1;
            this.horizontalLayout = !0;
            this.verticalLayout = !0;
            this.includeLinearizationInformation = !1
        }
        return n
    }(),
    OBrowserVisualizer = function() {
        function n(n) {
            this.MAXCHARPERLINE = 50;
            this.initialized = !1;
            this.isLoadFinished = !1;
            this.visualizationParams = new VisualizationOptions;
            this.oInfo = n
        }
        return n.prototype.shallowHierarchy = function() {
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 7);
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 1);
            OBrowserNavigation.getInstance().resetViewParamValueBit("V", 2);
            OBrowserNavigation.getInstance().resetViewParamValueBit("V", 3);
            this.visualizationSync(OBrowserNavigation.getInstance().getIdFromAddressBar())
        }, n.prototype.deepHierarchy = function() {
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 7);
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 1);
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 2);
            OBrowserNavigation.getInstance().resetViewParamValueBit("V", 3);
            this.visualizationSync(OBrowserNavigation.getInstance().getIdFromAddressBar())
        }, n.prototype.deeperHierarchy = function() {
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 7);
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 1);
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 2);
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 3);
            this.visualizationSync(OBrowserNavigation.getInstance().getIdFromAddressBar())
        }, n.prototype.verticalLayout = function() {
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 5);
            OBrowserNavigation.getInstance().resetViewParamValueBit("V", 4);
            this.setparamsFromAddressBar();
            this.breadthInitializated = !1
        }, n.prototype.horizontalLayout = function() {
            OBrowserNavigation.getInstance().setViewParamValueBit("V", 4);
            OBrowserNavigation.getInstance().resetViewParamValueBit("V", 5);
            this.setparamsFromAddressBar();
            this.breadthInitializated = !1
        }, n.prototype.centralLayout = function() {
            OBrowserNavigation.getInstance().resetViewParamValueBit("V", 4);
            OBrowserNavigation.getInstance().resetViewParamValueBit("V", 5);
            this.setparamsFromAddressBar();
            this.breadthInitializated = !1
        }, n.prototype.toggleLinearizationLinkages = function() {
            this.visualizationParams.includeLinearizationInformation ? OBrowserNavigation.getInstance().resetViewParamValueBit("V", 6) : OBrowserNavigation.getInstance().setViewParamValueBit("V", 6);
            this.visualizationSync(OBrowserNavigation.getInstance().getIdFromAddressBar())
        }, n.prototype.visualizationsInit = function() {
            this._icdRoot = {};
            this._icdRoot.ID = "http://id.who.int/icd/entity";
            this._icdRoot.label = "ICD";
            this._icdRoot.averageDepth = -1;
            this._icdRoot.isLeaf = !1;
            this._icdRoot.isAdoptedChild = !1;
            this.initialized = !0
        }, n.prototype.visualizationResized = function() {
            this.visualizationSync(OBrowserNavigation.getInstance().getIdFromAddressBar())
        }, n.prototype.dragstart = function() {
            this.force.stop()
        }, n.prototype.dragmove = function(n) {
            n.px += d3.event.dx;
            n.py += d3.event.dy;
            n.x += d3.event.dx;
            n.y += d3.event.dy;
            this.repositionGraph()
        }, n.prototype.dragend = function(n) {
            n.fixed = !0;
            this.repositionGraph()
        }, n.prototype.getNodeById = function(n, t) {
            for (var r, i = 0; i < t.length; ++i)
                if (r = t[i], n == r.ID) return r;
            return null
        }, n.prototype.finalize = function() {}, n.prototype.setparamsFromAddressBar = function() {
            this.visualizationParams.loadChildren = OBrowserNavigation.getInstance().isViewParamValueBitSet("V", 7);
            this.visualizationParams.loadParents = OBrowserNavigation.getInstance().isViewParamValueBitSet("V", 1);
            this.visualizationParams.includeAllAncestors = OBrowserNavigation.getInstance().isViewParamValueBitSet("V", 2);
            this.visualizationParams.loadAllAncestorsOfChildren = OBrowserNavigation.getInstance().isViewParamValueBitSet("V", 3);
            this.visualizationParams.horizontalLayout = OBrowserNavigation.getInstance().isViewParamValueBitSet("V", 4);
            this.visualizationParams.verticalLayout = OBrowserNavigation.getInstance().isViewParamValueBitSet("V", 5);
            this.visualizationParams.includeLinearizationInformation = OBrowserNavigation.getInstance().isViewParamValueBitSet("V", 6);
            $("#verticallayout").removeClass("vsidebuttonselected");
            $("#horizontallayout").removeClass("vsidebuttonselected");
            $("#centrallayout").removeClass("vsidebuttonselected");
            $("#moddetailicon").removeClass("vsidebuttonselected");
            $("#maxdetailicon").removeClass("vsidebuttonselected");
            $("#mindetailicon").removeClass("vsidebuttonselected");
            $("#verticallayout").addClass("vsidebutton");
            $("#horizontallayout").addClass("vsidebutton");
            $("#centrallayout").addClass("vsidebutton");
            $("#moddetailicon").addClass("vsidebutton");
            $("#maxdetailicon").addClass("vsidebutton");
            $("#mindetailicon").addClass("vsidebutton");
            this.visualizationParams.loadChildren && this.visualizationParams.includeAllAncestors && this.visualizationParams.loadAllAncestorsOfChildren ? ($("#maxdetailicon").addClass("vsidebuttonselected"), $("#maxdetailicon").removeClass("vsidebutton")) : this.visualizationParams.loadChildren && this.visualizationParams.includeAllAncestors && this.visualizationParams.loadAllAncestorsOfChildren == !1 ? ($("#moddetailicon").addClass("vsidebuttonselected"), $("#moddetailicon").removeClass("vsidebutton")) : this.visualizationParams.loadChildren && this.visualizationParams.includeAllAncestors == !1 && ($("#mindetailicon").addClass("vsidebuttonselected"), $("#mindetailicon").removeClass("vsidebutton"));
            this.visualizationParams.verticalLayout ? ($("#verticallayout").removeClass("vsidebutton"), $("#verticallayout").addClass("vsidebuttonselected")) : this.visualizationParams.horizontalLayout ? ($("#horizontallayout").removeClass("vsidebutton"), $("#horizontallayout").addClass("vsidebuttonselected")) : ($("#centrallayout").removeClass("vsidebutton"), $("#centrallayout").addClass("vsidebuttonselected"));
            this.visualizationParams.includeLinearizationInformation ? ($("#linlinkages").removeClass("vsidebutton"), $("#linlinkages").addClass("vsidebuttonselected")) : ($("#linlinkages").addClass("vsidebutton"), $("#linlinkages").removeClass("vsidebuttonselected"))
        }, n.prototype.visualizationSync = function(n) {
            var t, i;
            if (n != undefined)
                if (t = new Date, this._lastSynced == undefined) this._lastSynced = t, this.coreVisualizationSync(n);
                else {
                    if (i = t.getTime() - this._lastSynced.getTime(), i < 1e3) return;
                    this._lastSynced = t;
                    this.coreVisualizationSync(n)
                }
        }, n.prototype.coreVisualizationSync = function(n) {
            var t = this,
                i;
            if ((this.movedDueToCollision = [], this.currentItemId = n, this.breadthInitializated = !1, this.width = $("#visualization").width() - 20, this.height = OBrowserNavigation.getInstance().theLayout.innerLayout.state.container.innerHeight - 30, this.scaleMax = this.height - 35, this.nodes = [], this.links = [], this.initialized || this.visualizationsInit(), this.setparamsFromAddressBar(), i = n + ":" + this.width + ":" + this.height + OBrowserNavigation.getInstance().getViewParamValue("V"), this.lastSyncParam != i) && (this.lastSyncParam = i, n != undefined)) {
                this._dataLoader = new BrowserDataLoader(this.oInfo);
                this.visualizationParams.includeLinearizationInformation && this._dataLoader._oInfo.isLinearization ? this._dataLoader = new BrowserDataLoader(this.oInfo.getFoundationBasicInfo()) : this.visualizationParams.includeLinearizationInformation || this._dataLoader._oInfo.isLinearization || (this._dataLoader = new BrowserDataLoader(this.oInfo));
                $("#mainsvg").children().not("defs").detach();
                this.vis = d3.select("#mainsvg");
                this.vis.attr("width", this.width).attr("height", this.height);
                this.force = d3.layout.force().size([this.width, this.height]).nodes(this.nodes).links(this.links).gravity(.1).linkDistance(10).charge(function(n) {
                    return n.charge == undefined ? -1e3 : n.charge
                }).linkStrength(function(n) {
                    return n.strength
                }).friction(.9);
                this.nodesInView = this.vis.selectAll("g.node").attr("class", "svgg");
                this.linksInView = this.vis.selectAll("line.link").attr("class", "link");
                this.force.on("tick", function() {
                    t.visualizationParams.horizontalLayout ? t.depthBasedLayout(t.nodes, "H") : t.visualizationParams.verticalLayout && t.depthBasedLayout(t.nodes, "V");
                    t.manageOverflow(t.nodes);
                    t.manageCollision(t.nodes);
                    t.repositionGraph();
                    t.tickCount++
                });
                this.force.on("start", function() {
                    t.tickCount = 0
                });
                this.force.on("end", function() {
                    t.repositionGraph()
                });
                this.minBreadth = 1;
                this.maxBreadth = 0;
                this.maxDepth = 0;
                this.minDepth = 999;
                this._dataLoader.loadData(this.visualizationParams, n, function(n) {
                    t.addNode(n)
                }, function(n, i, r) {
                    n != "prevSibling" && (n == "parent" && t.addHierarchichalProperties(r, i), t.addLink(n, i, r, .9))
                }, function() {
                    return t.loadFinished()
                })
            }
        }, n.prototype.addNode = function(n) {
            var r = this,
                f, i, e, o, s, u, c, t, l, h;
            if (this.nodes.push(n), this.totalCount++, n.x == undefined && (n.x = this.width / 4 + Math.random() / 2 * this.width), n.y == undefined && (n.y = this.height / 4 + Math.random() / 2 * this.height), this.maxBreadth < n.breadthValue && (this.maxBreadth = n.breadthValue), this.minBreadth > n.breadthValue && (this.minBreadth = n.breadthValue), this.maxDepth < n.averageDepth && (this.maxDepth = n.averageDepth), this.breadthSpan = this.maxBreadth - this.minBreadth, this.minDepth > n.averageDepth && (this.minDepth = n.averageDepth), this.nodesInView = this.nodesInView.data(this.nodes), f = "svgg", n.ID == this.currentItemId && (f += " currentnode"), i = this.nodesInView.enter().append("svg:g").attr("class", f).attr("data-id", n.ID), e = d3.behavior.drag().on("dragstart", function() {
                    r.dragstart()
                }).on("drag", function(n) {
                    r.dragmove(n)
                }).on("dragend", function(n) {
                    r.dragend(n)
                }), i.append("svg:rect").attr("class", "svgrect").attr("x", -10).attr("y", -10).attr("width", 0).attr("height", 0), n.label.length < this.MAXCHARPERLINE) i.append("svg:text").attr("class", "svgtext").attr("x", 10).attr("y", 5).attr("onclick", "OBrowserNavigation.getInstance().gotoEntity('" + n.ID + "')").text(function(n) {
                return n.label
            }).append("title").text(function() {
                return "click to open this entity"
            });
            else {
                for (o = i.append("svg:text").attr("class", "svgtext").attr("x", 10).attr("y", 5).text(""), s = this.splitLines(n.label, this.MAXCHARPERLINE), u = 0; u < s.length; u++) c = o.append("tspan").text(s[u]), u > 0 && c.attr("x", 10).attr("dy", "15");
                o.attr("onclick", "OBrowserNavigation.getInstance().gotoEntity('" + n.ID + "')").append("title").text(function() {
                    return "click to open this entity"
                })
            }
            t = "nodecircle";
            n.ID == "http://id.who.int/icd/entity" && (t += " icdroot");
            n.linearizationInformation != null && n.linearizationInformation.length > 0 && _.where(n.linearizationInformation, {
                includedInLin: !0
            }).length > 0 && n.linearizationInformation.forEach(function(n) {
                n.includedInLin && (t += " linnode-" + n.linearizationName, t += " " + n.classKind + "-" + n.linearizationName)
            });
            n.isAdoptedChild && (t = t + " adopted");
            this.oInfo.isLinearization && n.classKind != undefined && (l = this.oInfo.getFoundationBasicInfo().ontologyId, h = this.oInfo.ontologyId.substring(l.length, this.oInfo.ontologyId.length), t += " linnode-" + h + " " + n.classKind + "-" + h);
            n.ID == this.currentItemId ? i.append("svg:circle").attr("r", 8).attr("class", t).call(e).append("title").text(function() {
                return "you may drag the node"
            }) : i.append("svg:circle").attr("r", 5).attr("class", t).call(e).append("title").text(function() {
                return "you may drag the node"
            });
            i[0].forEach(function(t) {
                if (t != null && (n.width = t.getBBox().width, n.width > .8 * r.width && (n.width = .8 * r.width), n.height = t.getBBox().height * .9, n.height == undefined));
            });
            this.repositionGraph()
        }, n.prototype.addLink = function(n, t, i, r) {
            var c = this.getNodeById(t.ID, this.nodes),
                l = this.getNodeById(i.ID, this.nodes),
                e, a, o, s, u, f, h;
            if (c != null && l != null && (e = _.find(this.links, function(r) {
                    return r.source.ID == t.ID && r.target.ID == i.ID && r.linkType == n
                }), e == undefined ? (o = {
                    source: c,
                    target: l,
                    invisible: !1,
                    strength: r,
                    linkType: n
                }, this.links.push(o), a = o) : a = e, this.linksInView = this.linksInView.data(this.links), s = this.linksInView.enter().append("svg:path").attr("class", "link"), u = s[0][s[0].length - 1], u != null)) {
                if (OBrowserNavigation.getInstance().getIdFromAddressBar() == i.ID ? this.addClass(u, "linktobig") : this.addClass(u, "linktonormal"), this.visualizationParams.includeLinearizationInformation && n == "parent" && t.linearizationInformation.length > 0)
                    for (f = 0; f < t.linearizationInformation.length; ++f) h = t.linearizationInformation[f], (h.parentId == i.ID || i.ID == this._icdRoot.ID) && this.addClass(u, "linParent-" + h.linearizationName);
                n == "parent" && this._dataLoader._oInfo.isLinearization && !t.isAdoptedChild && this.addClass(u, "linParent-" + this.oInfo.getLinearizationId());
                t.isAdoptedChild && n == "parent" && u.setAttribute("stroke-dasharray", "5,5");
                $("#mainsvg").children().not("defs").sort(function(n) {
                    return n.localName == "g" ? 1 : -1
                }).appendTo("#mainsvg");
                this.addClass(u, n)
            }
        }, n.prototype.loadFinished = function() {
            var t = this,
                n;
            this.groupManyChildren();
            var u = 1 / this.nodes.length,
                i = [],
                r = [];
            for (n = 0; n < 100; ++n) i[n] = 0, r[n] = 0;
            for (_(this.nodes).each(function(n) {
                    t._dataLoader._octEntities.initialize();
                    n.localAverageDepth = Math.floor(100 * (n.averageDepth - t.minDepth) / (t.maxDepth - t.minDepth + 1e-5));
                    n.localAverageBreadth = Math.floor(100 * (n.breadthValue - t.minBreadth) / (t.maxBreadth - t.minBreadth + 1e-5));
                    n.localAverageDepth >= 100 && (n.localAverageDepth = 99);
                    n.localAverageBreadth >= 100 && (n.localAverageBreadth = 99);
                    i[n.localAverageDepth] = i[n.localAverageDepth] + 1;
                    r[n.localAverageDepth] = r[n.localAverageDepth] + 1
                }), n = 1; n < 100; ++n) i[n] = i[n - 1] + i[n], r[n] = r[n - 1] + r[n];
            _(this.nodes).each(function(n) {
                n.normalizedLocalAverageDepth = i[n.localAverageDepth] * u;
                n.normalizedLocalAverageBreadth = r[n.localAverageBreadth] * u;
                n.y = t.scaleMax * .9 * n.normalizedLocalAverageDepth;
                n.x = t.scaleMax * n.normalizedLocalAverageBreadth
            });
            navigator.userAgent.indexOf("Trident") == -1 && ($(".linktobig").attr("marker-end", "url(#triangle1)"), $(".linktonormal").attr("marker-end", "url(#triangle2)"));
            this.force.start()
        }, n.prototype.groupManyChildren = function() {
            var n = this,
                t = [],
                i = 10,
                r = _.sortBy(this._dataLoader._octEntities.entities, function(n) {
                    return n.normalizedLocalAverageDepth
                });
            r.forEach(function(r, u) {
                var e = _.filter(r.children, function(n) {
                        return !_.contains(t, n.ID)
                    }),
                    v, h, s, p, w, o, b, k, u, a;
                if (!(e.length < 5))
                    for (v = Math.floor((e.length - 1) / i) + 1, h = Math.floor(e.length / v) + 1, s = 0; s < v; ++s) {
                        var c = e[s * h],
                            l = s * h,
                            y = Math.min(l + h - 1, e.length - 1),
                            f = {};
                        for (f.mainAnchor = !0, f.height = c.height, p = _.map(e.slice().splice(l, y), function(n, t) {
                                return n.width + 10 * t
                            }), w = _.max(p), f.averageDepth = c.averageDepth, f.breadthValue = c.breadthValue, f.width = w, f.ID = "group_" + c.ID, f.height = 0, f.mainAnchorIndent = 0, u = l; u <= y; ++u) o = e[u], t.push(o.ID), o.fixed = !0, u != l ? (b = e[u - 1], o.autolocateRelativeTo = b, f.width += 10, f.mainAnchorIndent -= 10) : o.autolocateRelativeTo = f, o.height == undefined && (k = 9), f.height += o.height + 5;
                        for (u = 0; u < n.links.length; ++u) a = n.links[u], (a.source.autolocateRelativeTo != undefined || a.target.autolocateRelativeTo != undefined) && (a.strength = 0);
                        n.nodes.push(f)
                    }
            })
        }, n.prototype.splitLines = function(n, t) {
            for (var u = [], f = 0, i = n, r = 0;;) {
                if (i[r] == " " && (f = r), r == t) {
                    u.push(i.substr(0, f));
                    i = i.substr(f + 1);
                    r = 0;
                    continue
                }
                if (r == i.length) {
                    u.push(i);
                    break
                }++r
            }
            return u
        }, n.prototype.addClass = function(n, t) {
            var i = n.getAttribute("class");
            i.indexOf(t) < 0 && $(n).attr("class", i + " " + t)
        }, n.prototype.repositionGraph = function() {
            var n = this;
            this.linksInView[0].forEach(function(t) {
                var i = t.__data__;
                i.invisible || n.drawBezier(t, i)
            });
            this.nodesInView[0].forEach(function(n) {
                var t = n.__data__,
                    r, i;
                t.ID.substr(0, 3) == "xxx" && (r = 9);
                $(n).attr("transform", "translate(" + (t.x + 10) + "," + t.y + ")");
                i = $(n).children("rect");
                i.attr("width", t.width + 10);
                i.attr("height", t.height + 4)
            })
        }, n.prototype.drawLine = function(n, t) {
            $(n).attr("x1", t.source.x + 10);
            $(n).attr("x2", t.target.x + 10);
            $(n).attr("y1", t.source.y);
            $(n).attr("y2", t.target.y)
        }, n.prototype.drawBezier = function(n, t) {
            var i, r, u, f, e, o, s;
            i = t.source.x + 10;
            r = t.target.x + 10;
            u = t.source.y;
            f = t.target.y;
            o = Math.min(f, u) + Math.abs((f - u) / 4);
            e = Math.min(r + 10, i + 10) + Math.abs((r + 10 - i + 10) / 4);
            s = "M" + i + " " + u + " Q " + e + " " + o + ", " + +r + " " + f;
            n.setAttribute("d", s)
        }, n.prototype.addHierarchichalProperties = function(n, t) {
            typeof n.children == "undefined" && (n.children = []);
            typeof t.parents == "undefined" && (t.parents = []);
            _.contains(n.children, t) || n.children.push(t);
            _.contains(t.parents, n) || t.parents.push(n)
        }, n.prototype.rectangleCollision = function(n, t) {
            return !(t.x > n.x + n.width || t.x + t.width < n.x || t.y > n.y + n.height + 6 || t.y + t.height + 6 < n.y)
        }, n.prototype.isNodeVisible = function(n) {
            return n.x >= 0 && n.x < this.width && n.y >= 0 && n.y < this.height ? !0 : !1
        }, n.prototype.depthBasedLayout = function(n) {
            var t = this,
                r = this.width / this.breadthSpan,
                u = this.maxBreadth - this.minBreadth + 1,
                i = 1 / 18;
            _(n).each(function(n) {
                var f, u;
                n.autolocateRelativeTo != undefined ? (n.autolocateRelativeTo.mainAnchor ? (f = n.autolocateRelativeTo.x - n.autolocateRelativeTo.mainAnchorIndent, u = n.autolocateRelativeTo.y) : (f = n.autolocateRelativeTo.x - 10, u = n.autolocateRelativeTo.y + n.autolocateRelativeTo.height + 5), t.setNodeVal(n, f, u, 1)) : t.maxDepth == t.minDepth ? t.setNodeVal(n, null, t.height / 2, i) : n.ID == "http://id.who.int/icd/entity" ? t.setNodeVal(n, t.width / 4, 20, i) : (n.mainAnchor ? (i = .9, u = t.scaleMax * n.normalizedLocalAverageDepth - n.height, f = null) : (u = t.scaleMax * .9 * n.normalizedLocalAverageDepth, f = (n.normalizedLocalAverageBreadth - t.minBreadth) * r), t.tickCount < 10 ? t.setNodeVal(n, f, u, i) : t.setNodeVal(n, null, u, i))
            })
        }, n.prototype.setNodeVal = function(n, t, i, r) {
            var e, u, o, f;
            t != null && (e = Math.abs((i - n.y) / n.height), u = (t - n.x) * r, n.x = n.x + u);
            i != null && (o = Math.abs((i - n.y) / n.height), f = (i - n.y) * r, n.y = n.y + f)
        }, n.prototype.manageOverflow = function(n) {
            for (var t, i = 0; i < n.length; ++i)(t = n[i], t.autolocateRelativeTo == undefined) && (t.x > this.width - t.width - 10 ? t.x = this.width - t.width - 10 : t.x < 3 && (t.x = 3), t.y > this.height - t.height - 3 ? t.y = this.height - t.height - 3 : t.y < 3 && (t.y = 3))
        }, n.prototype.manageCollision = function(n) {
            for (var l = 0, a = .1, v = _(n).sortBy(function(n) {
                    return n.normalizedLocalAverageBreadth
                }), t, s, i, f = 0; f < v.length; ++f)
                if (t = n[f], t.autolocateRelativeTo == undefined)
                    for (s = f + 1; s < v.length; ++s)
                        if (i = n[s], i.autolocateRelativeTo == undefined) {
                            var y = Math.min(10, this.tickCount / 10) / 10,
                                d = t.width * y,
                                g = i.width * y,
                                h = t.height,
                                nt = i.height,
                                u = t.x - i.x - .1,
                                r = t.y - i.y,
                                p = Math.abs(u),
                                w = Math.abs(r),
                                b = (1 - l) * (d + g + 40) / 2,
                                k = (1 - l) * (h + nt + 16) / 2,
                                c;
                            if (p < b && w < k) {
                                c = Math.sqrt(u * u + r * r);
                                var tt = Math.max(r, h - r) / h,
                                    e = (p - b) / c * a,
                                    o = (w - k) / c * a * tt * 10;
                                e > o && o > 0 ? e = 0 : o > e && e > 0 && (o = 0);
                                u *= e;
                                r *= o;
                                t.x -= u;
                                t.mainAnchor || (t.y -= r);
                                i.x += u;
                                i.mainAnchor || (i.y += r)
                            }
                        }
        }, n
    }()
