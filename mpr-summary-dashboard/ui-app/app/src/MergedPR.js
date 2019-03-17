import React from 'react';
import PropTypes from 'prop-types';
import {withStyles} from 'material-ui/styles';
import MilestoneMenuBar from './MilestoneMenuBar'
import axios from 'axios';
import "react-table/react-table.css";
import TextField from 'material-ui/TextField';
import PullRequestTable from './PullRequestTable';
import appendQuery from 'append-query';


var config = require('./config.json');

const hostUrl = config.url + config.service_path;

const styles = theme => ({
    container: {
        display: 'flex',
        flexWrap: 'wrap',
    },
    textField: {
        margin: theme.spacing.unit,
        minWidth: 500,
    },
    formControl: {
        margin: theme.spacing.unit,
        minWidth: 210,
    },
    menu: {
        width: 200,
    },
});


const States = ['Not Started', 'Draft Received', 'No Draft', 'In-progress', 'Issues Pending', 'Completed', 'No Impact'];


class MergedPR extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            error: null,
            isLoadedPrs: false,
            pullRequests: [],
            mapNumToStatus: null,
            searchText: '',
        };

        this.onSubmit = this.onSubmit.bind(this);
        this.handleStatusChange = this.handleStatusChange.bind(this);
        this.prFilter = this.prFilter.bind(this);
        this.onSearchTextChanged = this.onSearchTextChanged.bind(this);
    }

    onSubmit(info) {
        if (info.dateFrom === undefined || info.dateTo === undefined ||
            info.dateTo < info.dateFrom) {
            alert("Please select a valid date range to display pull requests.");
            return;
        } else if (info.version === undefined) {
            alert("There are no version entries of this product at the moment.");
            return;
        }

        let url = hostUrl + '/prs?';
        if (info.docStatus != 'All') {
            url = hostUrl + '/prsbystatus?';
            url=appendQuery(url, {status:info.docStatus})
        }
        url=appendQuery(url, {product:info.product})
        url=appendQuery(url, {version:info.version})
        url += '&start=' + info.dateFrom.toISOString();
        url += '&end=' + info.dateTo.toISOString();
       // url = encodeURI(url);
        axios.get(url)
            .then(response => {
                if (response.hasOwnProperty("data")) {
                    var mapNumToStatus = new Map();
                    for (var i in response.data.data) {
                        var pr = response.data.data[i];
                        var record = {
                            prId: pr.prId,
                            docStatus: pr.docStatus,
                            marketingStatus: pr.marketingStatus,
                        };
                        mapNumToStatus.set(pr.prId, record);
                    }
                    this.setState({
                        isLoadedPrs: response.data.data.length > 0,
                        pullRequests: response.data.data,
                        mapNumToStatus: mapNumToStatus,
                    });
                } else {
                    this.setState({
                        isLoadedPrs: false,
                        pullRequests: [],
                        mapNumToStatus: null,
                        error: "Could not load data from the backend.",
                    });
                }
            })
            .catch(error => {
                this.setState({
                    isLoadedPrs: false,
                    pullRequests: [],
                    mapNumToStatus: null,
                    error: error,
                });
            });

            //updating current url query params
            let data={
                product:info.product,
                version:info.version,
                status:info.docStatus,
                start:info.dateFrom.toISOString(),
                end:info.dateTo.toISOString()
            }
            let newurl =appendQuery(config.url,data);
            window.history.pushState(this.state, "List MPR", newurl);
    }

    handleStatusChange(event) {
        for (let node of event.target) {
            if (node.value === event.target.value) {
                let mapNumToStatus = new Map(this.state.mapNumToStatus);
                var key = parseInt(node.getAttribute('data-id'), 10);
                var value = States.indexOf(event.target.value);
                var record = mapNumToStatus.get(key);
                if (node.getAttribute('data-type') === 'doc')
                    record.docStatus = value;
                else if (node.getAttribute('data-type') === 'marketing')
                    record.marketingStatus = value;
                this.setState({
                    mapNumToStatus: mapNumToStatus,
                });

                axios.post(hostUrl + '/setdoc', {
                    records: [record],
                }, {
                    headers: {
                        "Accept": "application/json",
                        "Content-Type": "application/json",
                    }
                })
                    .then(response => {
                        console.log(response);
                    })
                    .catch(error => {
                        console.log(error);
                    });

                break;
            }
        }
    }

    prFilter(pr) {
        const searchText = this.state.searchText;
        if (searchText === '')
            return true;

        if (States[pr.docStatus].toLowerCase().includes(searchText.toLowerCase()))
            return true;

        if (States[pr.marketingStatus].toLowerCase().includes(searchText.toLowerCase()))
            return true;

        if (pr.prTitle.toLowerCase().includes(searchText.toLowerCase()))
            return true;

        return false;
    }

    onSearchTextChanged(e) {
        this.setState({
            searchText: e.target.value,
        });

    }

    render() {
        const {classes} = this.props;
        var pullRequests = this.state.pullRequests;
        pullRequests = pullRequests.filter(this.prFilter);

        if (this.state.error) {
            return (<p>{this.state.error}</p>);
        }
        return (
            <div>
                <MilestoneMenuBar
                    buttonText={'Display PRs'}
                    onSubmit={this.onSubmit}
                />

                {this.state.pullRequests.length > 0 &&
                <div>
                    <TextField
                        id="search"
                        label="Search"
                        type="search"
                        className={classes.textField}
                        margin="normal"
                        onChange={this.onSearchTextChanged}
                    />
                    <PullRequestTable data={pullRequests} editable={this.props.editable}/>
                </div>
                }
            </div>
        );
    }
}

MergedPR.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(MergedPR);